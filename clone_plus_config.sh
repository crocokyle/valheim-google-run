# Add to crontab: `echo "@reboot /home/htsbackupkyle/clone_plus_config.sh" > sudo crontab -e` 
sudo rm /home/htsbackupkyle/valheim-server/config/valheimplus/valheim_plus.cfg
sudo wget https://raw.githubusercontent.com/crocokyle/valheim-google-run/verve/valheim_plus.cfg /home/htsbackupkyle/valheim-server/config/valheimplus/valheim_plus.cfg
