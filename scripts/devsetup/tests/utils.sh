

function msgOK {
	echo "[OK]     "$1 
}


function msgFail {
	echo "[FAILED] "$1
	
	if [ $# -gt 1 ]
	then
		#print first line of fix
		echo -e " FIX:    "$2 | head -n 1
		
		#print other lines of fix with indent
		cnt=`echo -e $2 | wc -l`
		i=2
		while [ $i -le $cnt ]
		do
			echo -n "        "
			echo -e $2 | head -n $i | tail -n 1
			let i++
		done
	fi
}


function msgWarn {
	echo "[WARN]   "$1 
}


function checkProcessRunning {

	SERVICE=$1
	
	#test if process $SERVICE is running
	pid=`pidof $SERVICE`

	if [ -n "$pid" ]
	then
		echo "[OK]     $SERVICE is running"
		return 0
	else
		echo "[FAILED] $SERVICE is not running"
			 
		#print first line of fix
		echo " FIX:    start "$SERVICE
	fi
}