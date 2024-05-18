from phe import paillier
import sys


if __name__ == "__main__":
    if(sys.argv[1] == "1"):
        #生成密钥
        public_key, private_key = paillier.generate_paillier_keypair()
        print(public_key.n)
        print(public_key.g)
        print(private_key.p)
        print(private_key.q)
    else:
        pubKey = paillier.PaillierPublicKey(int(sys.argv[2]))
        if(sys.argv[1] == "2"):
            #加密
            print(pubKey.encrypt(int(sys.argv[3])).ciphertext())
        elif(sys.argv[1] == "3"):
            # 解密
            privateKey = paillier.PaillierPrivateKey(pubKey,int(sys.argv[3]),int(sys.argv[4]))
            print(privateKey.decrypt(paillier.EncryptedNumber(pubKey,int(sys.argv[5]))))  
        elif(sys.argv[1] == "4"):
            # 两个密文相加
            sum = paillier.EncryptedNumber(pubKey,int(sys.argv[3]))._add_encrypted(paillier.EncryptedNumber(pubKey,int(sys.argv[4])))
            print(sum.ciphertext())   
        