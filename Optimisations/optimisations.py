import copy
import re
import math

def is_power_of_2(n):
    try:
        n = int(n)
        return n and (not(n&(n-1)))
    except:
        return False

def display_quads():
    print("QUADRUPLES\n\n")
    print("op\targ1\targ2\tresult\n")
    for quad in quads:
        print('\t'.join(quad))
    print("\n")

def constant_folding():
    # quads_copy = copy.deepcopy(quads)
    quads_copy = quads
    pat = r"^[+-]?\d+.*\d*$"
    
    for quad in quads_copy:
        match1 = re.search(pat, quad[1])
        match2 = re.search(pat, quad[2])
        if(match1 and match2):
            temp = eval(quad[1] + quad[0] + quad[2])
            quad[0] = "="
            quad[1] = str(temp)
            quad[2] = ""

        # handling algebraic identities
        # case 1: x+0 = 0+x = x
        index_var = 0
        if(quad[1] == "0"):
            index_var = 2
        elif(quad[2] == "0"):
            index_var = 1
        if(quad[0] == "+" and index_var):
            quad[0] = "="
            quad[1] = quad[index_var]
            quad[2] = ""

        # case 2: x*1 = 1*x = x
        index_var = 0
        if(quad[1] == "1"):
            index_var = 2
        elif(quad[2] == "1"):
            index_var = 1
        if(quad[0] == "*" and index_var):
            quad[0] = "="
            quad[1] = quad[index_var]
            quad[2] = ""

        # case 3: a&&true = true&&a = a
        index_var = 0
        if(quad[1] == "true"):
            index_var = 2
        elif(quad[2] == "true"):
            index_var = 1
        if(quad[0] == "&&" and index_var):
            quad[0] = "="
            quad[1] = quad[index_var]
            quad[2] = ""

        # case 4: a||true = true||a = a
        index_var = 0
        if(quad[1] == "false"):
            index_var = 2
        elif(quad[2] == "false"):
            index_var = 1
        if(quad[0] == "||" and index_var):
            quad[0] = "="
            quad[1] = quad[index_var]
            quad[2] = ""

        # case 5: x*0=0*x=0
        if((quad[1] == "0" or quad[2] == "0") and quad[0] == "*"):
            quad[0] = "="
            quad[1] = "0"
            quad[2] = ""
        
        #case 6: 0/x = 0
        if(quad[1] == "0" and quad[0] == "/"):
            quad[0] = "="
            quad[1] = "0"
            quad[2] = ""
        
    # display_quads(quads_copy)

def constant_propagation():
    for i in range(len(quads)):
        pat = r"^[+-]?\d+.*\d*$"
        quad = quads[i]
        match = re.search(pat, quad[1])

        # case of constant assignment
        if(quad[0] == "=" and match and quad[2] == ""):
            var = quad[3]
            var_val = quad[1]
            for j in range(i+1, len(quads)):
                temp_quad = quads[j]
                if((temp_quad[3] != var)):
                    if(temp_quad[1] == var):
                        temp_quad[1] = var_val
                    elif(temp_quad[2] == var):
                        temp_quad[2] = var_val
                else:
                    break
    # display_quads(quads)

def constant_fold_propagate_opt():
    while(1):
        temp_quads = copy.deepcopy(quads)
        constant_folding()
        constant_propagation()
        if(quads == temp_quads):
            break
    # display_quads(quads)
        
def cse():
    quad_len = len(quads)
    i = 0
    while(i < quad_len):
        arg1 = quads[i][1]
        arg2 = quads[i][2]
        op = quads[i][0]
        replacement = quads[i][3]
        j = i + 1
        while(j < quad_len):
            if(quads[j][0] == op and quads[j][1] == arg1 and quads[j][2] == arg2):
                #to check if expr is being changed in between
                changed = False
                for iter in range(i+1, j):
                    if(quads[iter][3] == arg1 or quads[iter][3] == arg2):
                        changed = True
                        break
                if(not(changed)):
                    replacee = quads[j][3]
                    quads.remove(quads[j])
                    quad_len = quad_len - 1
                    for z in range(j, quad_len):
                        if(quads[z][1] == replacee):
                            quads[z][1] = replacement
                        if(quads[z][2] == replacee):
                            quads[z][2] = replacement
                        if(quads[z][3] == replacee):
                            quads[z][3] = replacement
                    # display_quads()
            j = j + 1
            
        i = i + 1

def strength_reduction():
    for quad in quads:
        if(quad[0] == "*"):
            ind_2 = 0
            other_ind = 0
            if(is_power_of_2(quad[1])):
                ind_2 = 1
                other_ind = 2
            elif(is_power_of_2(quad[2])):
                ind_2 = 2
                other_ind = 1
            if(ind_2):
                quad[0] = "<<"
                temp1 = quad[ind_2]
                temp2 = quad[other_ind]
                quad[1] = temp2
                quad[2] = str(int(math.log(int(temp1), 2)))
        elif(quad[0] == "/"):
            if(is_power_of_2(quad[2])):
                quad[0] = ">>"
                quad[2] = str(int(math.log(int(quad[2]), 2)))


if __name__ == "__main__":
    quads = list()
    quad_file = open("quads.txt", "r")
    quad_lines = quad_file.read().splitlines()

    for line in quad_lines:
        quads.append(line.split(','))
    
    # constant_folding()
    # display_quads()
    # constant_propagation()
    # display_quads()

    # constant_fold_propagate_opt()
    # display_quads()

    # cse()
    # display_quads()

    # strength_reduction()
    # display_quads()
