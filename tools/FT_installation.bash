DESTINATION=/$HOME/Tools/FastText/

rm -rf $DESTINATION
mkdir -pv /$HOME/Tools/

echo "export PATH=\$PATH:$DESTINATION/bin" >> ~/.bashrc

source ~/.bashrc

pushd $DESTINATION
	wget https://github.com/cservan/website/raw/master/tools/fastText.tar.gz
	tar xvfz fastText.tar.gz
    cd CRF++-0.58 && ./configure --prefix=/home/$USER/Tools/fastText && make && make install
popd

source ~/.bashrc
