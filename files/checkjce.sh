jrunscript -e "exit(javax.crypto.Cipher.getMaxAllowedKeyLength('RC5') >= 256)"
if [[ $? == 1 ]]; then
	echo jce unlimit enable
else
	echo jce unlimit not enable
fi
