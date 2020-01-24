DESTINATION=/$HOME/Tools/SRILM-1.6.0

rm -rf $DESTINATION
mkdir -pv $DESTINATION
echo "export PATH=\$PATH:$DESTINATION/bin/i686-m64/" >> ~/.bashrc
echo "export SRILM=$DESTINATION" >> ~/.bashrc

. ~/.bashrc

pushd $DESTINATION
	wget https://cservan.github.io/website/tools/srilm-1.6.0.tar.gz
	tar xvfz srilm-1.6.0.tar.gz
# for linux:    
	SRILM=$DESTINATION make MACHINE_TYPE=i686-m64 World -j4
# for macOS:
#	SRILM=$DESTINATION make MACHINE_TYPE=macosx-m64 World -j4
#
popd

source ~/.bashrc
