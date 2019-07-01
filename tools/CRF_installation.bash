DESTINATION=/$HOME/Tools/CRF++

rm -rf $DESTINATION
mkdir -pv /$HOME/Tools/

echo "export PATH=\$PATH:$DESTINATION/bin" >> ~/.bashrc

source ~/.bashrc

pushd $DESTINATION
	wget https://github.com/cservan/website/raw/master/tools/CRF%2B%2B-0.58.tar.gz
	tar xvfz CRF++-0.58.tar.gz
    cd CRF++-0.58 && ./configure --prefix=/home/$USER/Tools/CRF++-0.58 && make && make install
popd

source ~/.bashrc
