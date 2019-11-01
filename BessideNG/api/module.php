<?php namespace pineapple;

class BessideNG extends Module
{
    public function route()
    {
        switch ($this->request->action) {
            case 'refreshInfo':
                $this->refreshInfo();
                break;
            case 'refreshStatus':
                $this->refreshStatus();
				break;
			case 'handleDependenciesStatus':
                $this->handleDependenciesStatus();
                break;
			case 'handleDependencies':
                $this->handleDependencies();
                break;
            case 'getInterfaces':
                $this->getInterfaces();
                break;
            case 'getMonitors':
                $this->getMonitors();
                break;
            case 'startMonitor':
                $this->startMonitor();
                break;
            case 'stopMonitor':
                $this->stopMonitor();
                break;
			case 'toggleBessideNG':
                $this->toggleBessideNG();
                break;
            case 'toggleBessideNGOnBoot':
                $this->toggleBessideNGOnBoot();
                break;
            case 'saveAutostartSettings':
                $this->saveAutostartSettings();
                break;
            case 'refreshOutput':
                $this->refreshOutput();
                break;
            case 'refreshCaptures':
                $this->refreshCaptures();
                break;
            case 'viewCapture':
                $this->viewCapture();
                break;
            case 'deleteCapture':
                $this->deleteCapture();
                break;
            case 'downloadCapture':
                $this->downloadCapture();
                break;
        }
    }
    
    /* BessideNG_Controller */
    
    protected function refreshInfo() {
        $moduleInfo = @json_decode(file_get_contents("/pineapple/modules/BessideNG/module.info"));
        $this->response = array('title' => $moduleInfo->title, 'version' => $moduleInfo->version);
    }
    
    /* BessideNG_ControlsController */
    
    private function refreshStatus() {
        if (!file_exists('/tmp/BessideNG.progress')) {
            if (!$this->checkDeps("besside-ng")) {
                $installed = false;
                $install = "Not installed";
                $installLabel = "danger";
                $processing = false;

                $status = "Start";
                $statusLabel = "success";

                $bootLabelON = "default";
                $bootLabelOFF = "danger";
            } else {
                $installed = true;
                $install = "Installed";
                $installLabel = "success";
                $processing = false;

                if ($this->checkRunning("besside-ng")) {
                    $status = "Stop";
                    $statusLabel = "danger";
                } else {
                    $status = "Start";
                    $statusLabel = "success";
                }

                if (exec("cat /etc/rc.local | grep BessideNG/scripts/autostart_besside.sh") == "") {
                    $bootLabelON = "default";
                    $bootLabelOFF = "danger";
                } else {
                    $bootLabelON = "success";
                    $bootLabelOFF = "default";
                }
            }
        } else {
            $installed = false;
            $install = "Installing...";
            $installLabel = "warning";
            $processing = true;

            $status = "Not running";
            $statusLabel = "danger";
            $verbose = false;

            $bootLabelON = "default";
            $bootLabelOFF = "danger";
        }

        $device = $this->getDevice();
        $sdAvailable = $this->isSDAvailable();

        $this->response = array(
        	"device" => $device,
        	"sdAvailable" => $sdAvailable,
        	"status" => $status,
        	"statusLabel" => $statusLabel,
        	"installed" => $installed,
        	"install" => $install,
        	"installLabel" => $installLabel,
        	"bootLabelON" => $bootLabelON,
        	"bootLabelOFF" => $bootLabelOFF,
        	"processing" => $processing
        );
    }
    
    private function handleDependenciesStatus() {
        if (!file_exists('/tmp/BessideNG.progress')) {
            $this->response = array('success' => true);
        } else {
            $this->response = array('success' => false);
        }
    }
    
    private function handleDependencies() {
        if (!$this->checkDeps("besside-ng")) {
            $this->execBackground("/pineapple/modules/BessideNG/scripts/dependencies.sh install ".$this->request->destination);
            $this->response = array('success' => true);
        } else {
            $this->execBackground("/pineapple/modules/BessideNG/scripts/dependencies.sh remove");
            $this->response = array('success' => true);
        }
    }
    
    private function getInterfaces() {
        exec("iwconfig 2> /dev/null | grep \"wlan*\" | grep -v \"mon*\" | awk '{print $1}'", $interfaceArray);
        $this->response = array("interfaces" => $interfaceArray);
    }

    private function getMonitors() {
        exec("iwconfig 2> /dev/null | grep \"mon*\" | awk '{print $1}'", $monitorArray);
        $this->response = array(
            "monitors" => $monitorArray,
        	"selected" => reset(preg_grep('/^'.$this->uciGet("BessideNG.run.interface").'/', $monitorArray))
        );
    }

    private function startMonitor() {
        exec("airmon-ng start ".$this->request->interface);
    }

    private function stopMonitor() {
        exec("airmon-ng stop ".$this->request->monitor);
    }
    
    private function toggleBessideNG() {
        if (!$this->checkRunning("besside-ng")) {
            $this->uciSet("BessideNG.run.interface", $this->request->interface);
            $this->execBackground("/pineapple/modules/BessideNG/scripts/besside.sh start");
        } else {
            //$this->uciSet("BessideNG.run.interface", '');
            $this->execBackground("/pineapple/modules/BessideNG/scripts/besside.sh stop");
        }
    }
    
    private function toggleBessideNGOnBoot() {
        if (exec("cat /etc/rc.local | grep BessideNG/scripts/autostart_besside.sh") == "") {
            exec("sed -i '/exit 0/d' /etc/rc.local");
            exec("echo /pineapple/modules/BessideNG/scripts/autostart_besside.sh >> /etc/rc.local");
            exec("echo exit 0 >> /etc/rc.local");
        } else {
            exec("sed -i '/BessideNG\/scripts\/autostart_besside.sh/d' /etc/rc.local");
        }
    }
    
    private function saveAutostartSettings() {
        $settings = $this->request->settings;
        $this->uciSet("BessideNG.autostart.interface", rtrim($settings->interface, 'mon'));
    }
    
    /* BessideNG_OwnedController */
    
    private function refreshOutput() {
	    $this->streamFunction = function () {
		    echo '{"running":'.json_encode($this->checkRunning("besside-ng")).',"owned":';
		    echo '[';
		    $log = "/pineapple/modules/BessideNG/log/".$this->uciGet("BessideNG.run.log")."/besside.log";
		    if ($this->checkRunning("besside-ng") && file_exists($log)) {
		        $handle = fopen($log, "r");
		        $skipfirst = 2;
		        if ($handle) {
			        while (($line = fgets($handle)) !== false) {
				        if ($skipfirst > 0) {
					        $skipfirst = $skipfirst-1;
					        if ($skipfirst == 1) {
						        continue;
					        }
				        } else {
					        echo ',';
				        }
				        echo json_encode(array_map("trim", explode(" | ", $line)));
				    }
				    fclose($handle);
				}
	        }
		    echo ']}';
		};
    }
    
    /* BessideNG_HistoryController */

    private function refreshCaptures() {
        $this->streamFunction = function () {
            $log_list = array_reverse(glob("/pineapple/modules/BessideNG/log/*"));

            echo '[';
            for ($i=0;$i<count($log_list);$i++) {
	            $entryName = basename($log_list[$i]);
                $entryDate = gmdate('Y-m-d H-i-s', $entryName);
                
                $WPA = intval(exec("cat {$log_list[$i]}/besside.log | grep 'Got WPA handshake' | wc -l"));
                $WEP = intval(exec("cat {$log_list[$i]}/besside.log | grep -v 'Got WPA handshake' | wc -l")) -1;
                
                $owned = "Nothing owned :'(";
                if ($WPA > 0 && $WEP > 0) {
	            	$owned = "{$WEP} WEP & {$WPA} WPA";
                } else if ($WPA > 0) {
	                $owned = "{$WPA} WPA";
                } else if ($WEP > 0) {
	                $owned = "{$WEP} WEP";
                }
                
                $entryWepSize = $this->human_filesize(filesize($log_list[$i]."/wep.cap"));
                $entryWpaSize = $this->human_filesize(filesize($log_list[$i]."/wpa.cap"));
                
                $disableDelete = $i == 0 && $this->checkRunning("besside-ng");

                echo json_encode(array($entryName, $entryDate, $owned, $entryWepSize, $entryWpaSize, $disableDelete));

                if ($i!=count($log_list)-1) {
                    echo ',';
                }
            }
            echo ']';
        };
    }
    
    private function viewCapture() {
        $log_date = gmdate("F d Y H:i:s", filemtime("/pineapple/modules/BessideNG/log/".$this->request->file."/besside.log"));
        exec("cat /pineapple/modules/BessideNG/log/".$this->request->file."/besside.log", $output);

        if (!empty($output)) {
            $this->response = array("output" => implode("\n", $output), "date" => $log_date);
        } else {
            $this->response = array("output" => "Empty log...", "date" => $log_date);
        }
    }

    private function deleteCapture() {
        exec("rm -rf /pineapple/modules/BessideNG/log/".$this->request->file);
    }

    private function downloadCapture() {
        $this->response = array( "download" => $this->downloadFile("/pineapple/modules/BessideNG/log/".$this->request->file) );
    }
    
    
    // View captures idea
    
    // tcpdump -enr /pineapple/modules/BessideNG/wep.cap '(type mgt subtype beacon)' | cut -d' ' -f2- | sort | uniq
    
    

	/* Protected */
    
    protected function checkDeps($dependencyName) {
        return ($this->checkDependency($dependencyName) && ($this->uciGet("BessideNG.module.installed")));
    }

    protected function checkRunning($processName)
    {
        return exec("ps x | grep {$processName} | grep -v grep") !== '' ? 1 : 0;
    }

    protected function getDevice() {
        return trim(exec("cat /proc/cpuinfo | grep machine | awk -F: '{print $2}'"));
    }
    
    protected function human_filesize($bytes, $decimals = 2) {
		$sz = 'BKMGTP';
		$factor = floor((strlen($bytes) - 1) / 3);
		return sprintf("%.{$decimals}f", $bytes / pow(1024, $factor)) . @$sz[$factor];
	}
}
