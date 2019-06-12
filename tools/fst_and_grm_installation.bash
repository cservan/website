DESTINATION=$HOME/Tools/
TMP=$HOME/Tools/Sources

mkdir -pv $TMP
pushd $TMP
	wget http://www-clips.imag.fr/geod/User/christophe.servan/tools/openfst-1.5.0.tar.gz
	wget http://www-clips.imag.fr/geod/User/christophe.servan/tools/opengrm-ngram-1.2.1.tar.gz	
	tar xvfz openfst-1.5.0.tar.gz
	tar xvfz opengrm-ngram-1.2.1.tar.gz
	pushd openfst-1.5.0 

		./configure --prefix=$DESTINATION/openfst-1.5.0/ --enable-far --enable-static
		make 
		make install
	popd
	pushd opengrm-ngram-1.2.1
		CXXFLAGS=-I$DESTINATION/openfst-1.5.0/include/ CFLAGS=-I$DESTINATION/openfst-1.5.0/include/ LDFLAGS="-L$DESTINATION/openfst-1.5.0/lib/ -L$DESTINATION/openfst-1.5.0/lib/fst" ./configure --prefix=$DESTINATION/opengrm-1.2.1/
		make
		make install
	popd
	echo "export PATH=\$PATH:$DESTINATION/openfst-1.5.0/bin/:$DESTINATION/opengrm-1.2.1/bin" >> ~/.bashrc
popd
. ~/.bashrc


