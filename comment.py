with open(r"C:\Users\home\Desktop\py\CLINCAL_TRIMED_APID9617_MERGE.sh", "rt") as fin:
    for line in fin:
        if line.startswith("/*") :
          print(line)
        elif  line.endswith("*/"):
          print(line.strip())
