exp_value = {}
with open(r"C:\Users\home\Desktop\py\AFC_EDW_CLM_PARM.parm", 'rt') as rplc:
    for _i in rplc:
        if _i.startswith('export'):
            _i = _i.replace('export', '').replace('/n', '')
            key_value = _i.split('=')
            exp_value[f'${key_value[0].lstrip()}'] = key_value[1]
with open(r"C:\Users\home\Desktop\py\CLINCAL_TRIMED_APID9617_MERGE.sh", "rt") as fin:
    with open(r"C:\Users\home\Desktop\py\log.txt", "wt") as fout:
        i = 0
        j = 0
        for line in fin:
            if line.startswith('bteq') and 'EOF' in line:
                j = 1
            elif 'EOF' in line:
                j = 0
            if not j:
                if 'EOF' not in line:
                    line = ''
            elif j:

                if line.startswith('#'):
                    line = ''
                elif line.startswith('/*') or line.startswith('*') or i:
                    line = ''
                    i = 1 if i == 0 and 'Error Handling' in line else 0
                else:
                    for _s in exp_value.keys():
                        if _s in line:
                            if '$LOGON/$LOGON_ID' in line:
                                line = line.replace('$LOGON/$LOGON_ID', exp_value.get(_s))
                            else:
                                line = line.replace(_s, exp_value.get(_s))
            if 'default database' in line:
                line = ''
            fout.write(line)

exp_value = {}
