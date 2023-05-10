FROM mmmmcoffee/nimplantv3:0.0.2
ENV PATH="${PATH}:/root/.nimble/bin:$PATH"
RUN python3 -m pip install mythic-container==0.2.0rc4
WORKDIR /Mythic/
CMD ["python3", "main.py"]

#apt update && apt install -y mingw-w64
#curl https://nim-lang.org/choosenim/init.sh -sSf | sh 
#ENV PATH="${PATH}:/root/.nimble/bin:$PATH"

#nimble install -y winim 
#nimble install -y nimcrypto
#nimble install -y puppy
