def  converteArroba(line):
    '''

    > Exemplo de instrução:
    
    Recebe :
        JMP @2
    Retorna : 
        & '0' & x"02"
    
    '''

    line = line.split('@')
    if(int(line[1]) > 255 ):
        number = str(int(line[1]) - 256)
    else:
        number = line[1]

    hex_number = hex(int(number))[2:].upper().zfill(2)
    number_format = " & '0' & x\"" + hex_number + "\""

    return number_format
  
def  converteCifrao(line):
    '''

    > Exemplo de instrução:
    
    1 . LDI $5 
    
    '''

    line = line.split('$')
    if(int(line[1]) > 255 ):
        number = str(int(line[1]) - 256)
    else:
        number = line[1]

    hex_number = hex(int(number))[2:].upper().zfill(2)
    number_format = " & '0' & x\"" + hex_number + "\""
    
    return number_format

def defineComentario(line):
    '''

    > Definição de comentário:
    
    1 . JSR @14 #comentario1
    
    '''
    if '#' in line:
        line = line.split('#')
        comentario = line[1]
        return comentario
    else:
        return line

def defineInstrucao(line):
    '''
    Retorna apenas a instrução:

    JSR @14 #comentario1  -> JSR @14

    '''

    line = line.split('#')
    line = line[0]
    return line

def defineOpCode(line):
    '''
    Recebe : JSR @14

    Retorna : JSR
    
    '''

    if '@' in line : 
        split_by = '@'
    elif '$' in line:
        split_by = '$'
    elif '.' in line:
        split_by = '.'
    else:
        return line.strip()
    
    line  = line.split(split_by)
    opcode = line[0].strip()
    return opcode

def tableLabel(lines):
    '''
    Cria tabela hash de correspondência : LABEL -> linha
    '''

    hash_table = {}
    count = 0

    for line in lines:
        if(line.startswith('.')):

            label = line.replace('.' , '')
            label = label.strip()

            hash_table[label] = count
        
        if((line.startswith('#')) or (line.startswith('\n')) or (line.startswith('.'))):
            pass
        else:
            count+=1
            
    return hash_table

def carregaArquivo(filename):
    with open(filename, "r") as f: 
        data = f.readlines() 

    return data


def main(fileASM , fileBIN):

    '''
    Tranforma o código em Assembly em código de máquina (entendido pela memória ROM).
    
    > Entrada :
        JSR @14 #comentario1
    
    > Saída :
        tmp(0) := JSR & '0' & x"0E";	-- JSR @14 	#comentario1
    
    '''

    # Contagem de linhas
    count = 0

    # Abre arquivo
    with open(fileBIN, "w+") as f: 

        # Carrega dados
        lines  = carregaArquivo(fileASM)

        # Lables
        dict_labels = tableLabel(lines)

        for line in lines:        
                                                                
            comentario = defineComentario(line).replace("\n","")         # Ex( JSR @14 #comentario1 ) :  comentario1
            instrucao  = defineInstrucao(line).replace("\n","")          # Ex( JSR @14 #comentario1 ) :  JSR @14
            opcode     = defineOpCode(instrucao)                         # Ex( JSR @14 #comentario1 ) :  JSR

            if '@' in instrucao: 
                number_hex_format = converteArroba(instrucao)            # Ex(JSR @14) : & '0' & x"0E"

            elif '$' in instrucao:
                number_hex_format = converteCifrao(instrucao)            # Ex(LDI $5)  : & '0' & x"05"

            elif (not(line.startswith('.')) and ('.' in instrucao)):     # Trata operações do tipo : JMP .LABEL
               
                label = instrucao.split('.')[-1].strip()
                number_line = dict_labels[label]
                
                number_line_hex = hex(int(number_line))[2:].upper().zfill(2)
                number_hex_format =  " & '0' & x\"" + number_line_hex + "\""
                instrucao = opcode + " @" + str(number_line)
                
            elif ('RET' in instrucao) or ('NOP' in instrucao):
                number_hex_format =  " & " + "\'0\' & " + "x\"00" + "\""
            
            else:
                
                if(line.startswith('#')):
                    # Linha de comentário
                    line = '-- ' + comentario + '\n'
                    f.write(line)
                else:
                    # Quebra de linha :  manter quebra de linha no arquivo:
                    f.write('\n')

                continue

            # Remove a quebra de linha
            instrucao = instrucao.replace("\n", "") 
              
            # Formata
            if (comentario  == instrucao):
                line = 'tmp(' + str(count) + ') := ' + opcode + number_hex_format + ';\t-- #' + instrucao + '\n'
            else:
                line = 'tmp(' + str(count) + ') := ' + opcode + number_hex_format + ';\t-- #' + instrucao + '\t-- ' + comentario + '\n'
                                                                                                                                    
            count+=1 
            f.write(line)

if __name__ == "__main__":
    
    # Arquivo com Assembly
    inputASM = 'ASM.txt'  

    #Arquivo com Binário VHDL    
    outputBIN = 'BIN.txt'    
    
    # Formatacao .mif
    outputMIF = 'initROM.mif'

    main(inputASM , outputBIN)