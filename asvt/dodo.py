with open('C:/Users/Roman/Desktop/asvt/just_obraz.img', 'rb') as file:
    with open('C:/Users/Roman/Desktop/asvt/prog.com', 'rb') as wfile:
        text = wfile.read()
        print(len(text))
        ftext = file.read()
        print(len(ftext))
        empty = b'\00' * 13824
        for k in range(1, 13):
            n = str(k)
            name = b'\00\01' + b'programm' + bytes(n, encoding="ascii")
            print(name)
            ftext = ftext[:4096 + 32*k] + name + ftext[4096 + 32*k + len(name):]
        for j in range(0, 13):
            ftext = ftext[:4608 + 13824 * j] + empty + ftext[4608 + len(empty) + 13824 * j:]
            ftext = ftext[:4608 + 13824 * j] + text + ftext[4608 + len(text) + 13824 * j:]
        print(len(ftext))
with open('C:/Users/Roman/Desktop/asvt/obraz.img', 'wb') as file:
    file.write(ftext)