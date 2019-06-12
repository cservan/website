DESTINATION=/$HOME/Tools/fastText

rm -rf $DESTINATION
mkdir -pv /$HOME/Tools/

source ~/.bashrc

pushd $DESTINATION
	git clone https://github.com/facebookresearch/fastText.git
    cd fastText && mkdir build && cd build && cmake .. && make
    sudo make install
popd

source ~/.bashrc
