DESTINATION=/$HOME/Tools/fastText/

rm -rf $DESTINATION
mkdir -pv $DESTINATION

echo "export PATH=\$PATH:$DESTINATION/bin" >> ~/.bashrc

source ~/.bashrc

pushd $DESTINATION
	wget https://github.com/cservan/website/raw/master/tools/fastText.tar.gz
	tar xvfz fastText.tar.gz
    cd fastText && mkdir build && cd build && cmake .. -DCMAKE_INSTALL_PREFIX=$DESTINATION && make -j && make install
popd

source ~/.bashrc
