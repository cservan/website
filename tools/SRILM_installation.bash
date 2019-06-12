DESTINATION=/$HOME/Tools/SRILM-1.6.0


mkdir -pv $DESTINATION
echo "export PATH=\$PATH:$DESTINATION/bin/i686-m64/" >> ~/.bashrc
echo "export SRILM=$DESTINATION" >> ~/.bashrc

. ~/.bashrc

pushd $DESTINATION
	wget http://www-clips.imag.fr/geod/User/christophe.servan/tools/srilm-1.6.0.tar.gz
	tar xvfz srilm-1.6.0.tar.gz
	SRILM=$DESTINATION make MACHINE_TYPE=i686-m64 World -j4
popd

. ~/.bashrc
