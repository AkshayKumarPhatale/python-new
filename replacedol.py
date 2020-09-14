import re
#$(( )) pending
dl=[]
rl=[]
flag=False
startposition=0
endposition=0
dollarstartposition=0
bracketposition=0
pattern="^[0-9]$"
with open(r"C:\Users\home\Desktop\py\abc.txt", "rt") as fin:
    for line in fin:
        dl.append(line)

    for text in dl:
        if '$' in text:
            for element in range(0, len(text)):
                if text[element] == "$":
                    flag = True
                    startposition = element

                elif flag:
                    if re.search(pattern, text[element]):
                          continue
                    elif text[element] == ";" or text[element] == "\'" or text[element] == "." or text[element] == ")":

                        endposition = element
                        s=text[startposition+1:endposition]
                        print(s)
                        flag = False
                    elif text[element] == "(":
                        startposition=element




#for item in rl:
#print(item)