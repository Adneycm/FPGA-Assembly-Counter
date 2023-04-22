library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity memoriaROM is
   generic (
          dataWidth: natural := 4;
          addrWidth: natural := 3
    );
   port (
          Endereco : in std_logic_vector (addrWidth-1 DOWNTO 0);
          Dado : out std_logic_vector (dataWidth-1 DOWNTO 0)
    );
end entity;

architecture assincrona of memoriaROM is

  constant NOP  : std_logic_vector(3 downto 0) := "0000";
  constant LDA  : std_logic_vector(3 downto 0) := "0001";
  constant SOMA : std_logic_vector(3 downto 0) := "0010";
  constant SUB  : std_logic_vector(3 downto 0) := "0011";
  constant LDI  : std_logic_vector(3 downto 0) := "0100";
  constant STA  : std_logic_vector(3 downto 0) := "0101";
  constant JMP  : std_logic_vector(3 downto 0) := "0110";
  constant JEQ  : std_logic_vector(3 downto 0) := "0111";
  constant CEQ  : std_logic_vector(3 downto 0) := "1000";
  constant JSR  : std_logic_vector(3 downto 0) := "1001";
  constant RET  : std_logic_vector(3 downto 0) := "1010";
  
  type blocoMemoria is array(0 TO 2**addrWidth - 1) of std_logic_vector(dataWidth-1 DOWNTO 0);

  function initMemory
        return blocoMemoria is variable tmp : blocoMemoria := (others => (others => '0'));
  begin
				
--  INICIALIZAÇÃO DO COMPUTADOR

--  Zerando os displays de sete segmentos
tmp(0) := LDI & '0' & x"00";	-- LDI $0   	--  Carrega o acumulador com o valor 0
tmp(1) := STA & '1' & x"20";	-- STA @288 	--  Armazena o valor do acumulador em HEX0
tmp(2) := STA & '1' & x"21";	-- STA @289 	--  Armazena o valor do acumulador em HEX1
tmp(3) := STA & '1' & x"22";	-- STA @290 	--  Armazena o valor do acumulador em HEX2
tmp(4) := STA & '1' & x"23";	-- STA @291 	--  Armazena o valor do acumulador em HEX3
tmp(5) := STA & '1' & x"24";	-- STA @292 	--  Armazena o valor do acumulador em HEX4
tmp(6) := STA & '1' & x"25";	-- STA @293 	--  Armazena o valor do acumulador em HEX5

--  Apagando os LEDs
tmp(7)  := LDI & '0' & x"00";	-- LDI $0	 	--  Carrega o acumulador com o valor 0
tmp(8)  := STA & '1' & x"00";	-- STA @256 	--  Armazena o valor do bit0 do acumulador no LDR0 ~ LEDR7
tmp(9)  := STA & '1' & x"01";	-- STA @257 	--  Armazena o valor do bit0 do acumulador no LDR8
tmp(10) := STA & '1' & x"02";	-- STA @258 	--  Armazena o valor do bit0 do acumulador no LDR9


--  Inicializando posicao de constantes imutáveis
tmp(11) := LDI & '0' & x"00";	-- LDI $0 --  Constante 0
tmp(12) := STA & '0' & x"00";	-- STA @0 
tmp(13) := LDI & '0' & x"01";	-- LDI $1 --  Constante 1
tmp(14) := STA & '0' & x"01";	-- STA @1
tmp(15) := LDI & '0' & x"09";	-- LDI $9 --  Constante 9
tmp(16) := STA & '0' & x"09";	-- STA @9

--  Inicializando posições que guardaram Unidades do contador
tmp(17) := LDI & '0' & x"00";	-- #LDI $0
tmp(18) := STA & '0' & x"0A";	-- #STA @10       	--  MEN[10] = Unidades
tmp(19) := STA & '0' & x"0B";	-- #STA @11       	--  MEN[11] = Dezenas
tmp(20) := STA & '0' & x"0C";	-- #STA @12       	--  MEN[12] = Centenas
tmp(21) := STA & '0' & x"0D";	-- #STA @13       	--  MEN[13] = Unidade de Milhar
tmp(22) := STA & '0' & x"0E";	-- #STA @14       	--  MEN[14] = Centena de Milhar
tmp(23) := STA & '0' & x"0F";	-- #STA @15       	--  MEN[15] = Unidade de Milhão


--  LÓGICA DO CONTADOR
tmp(24) := LDA & '1' & x"60";	-- LDA @352 Carrega o acumulador com a leitura do botão KEY0
tmp(25) := CEQ & '0' & x"01";	-- CEQ @1   Compara com valor armazenado em MEM[1]
tmp(26) := JEQ & '0' & x"1D";	-- JEQ @29  Pula para SUB-rotina soma unidades
tmp(27) := NOP & '0' & x"00"; -- NOP
tmp(28) := JMP & '0' & x"18";	-- JMP @24 


--  SUB-rotina soma unidades
tmp(29) := STA  & '1' & x"FF"; -- Limpa flipflop KEY0
tmp(30) := LDA  & '0' & x"0A"; -- LDA @10   Carrega o acumulador com o valor de MEM[10] (unidades)

tmp(31) := CEQ  & '0' & x"09"; -- CEQ @9   Verifica se o digito é igual a 9
tmp(32) := JEQ  & '0' & x"26"; -- JEQ @38  Se o digito for igual a 9, pula para SUB-rotina soma dezenas

tmp(33) := SOMA & '0' & x"01"; -- SOMA @1  Soma acumulador com valor da MEM[1] (1)
tmp(34) := STA  & '0' & x"0A"; -- STA @10  Armazena o valor do acumulador em MEM[10] (unidades)
tmp(35) := STA  & '1' & x"20"; -- STA @288 Armazena o valor do acumulador em HEX0
tmp(36) := JMP  & '0' & x"18"; -- JMP @24
tmp(37) := NOP  & '0' & x"00"; -- #NOP
------------------------------

--  SUB-rotina soma dezenas
tmp(38) := LDI  & '0' & x"00"; -- LDI $0 --  Constante 0
tmp(39) := STA  & '0' & x"0A"; -- STA @10  Armazena o valor do acumulador em MEM[10] (unidades)
tmp(40) := STA  & '1' & x"20"; -- STA @288 Armazena o valor do acumulador em HEX0

tmp(41) := LDA  & '0' & x"0B"; -- LDA @11   Carrega o acumulador com o valor de MEM[11] (dezenas)
tmp(42) := CEQ  & '0' & x"09"; -- CEQ @9   Verifica se o digito é igual a 9
tmp(43) := JEQ  & '0' & x"31"; -- JEQ @49  Se o digito for igual a 9, pula para SUB-rotina soma centenas

tmp(44) := SOMA & '0' & x"01"; -- SOMA @1  Soma acumulador com valor da MEM[1] (1)
tmp(45) := STA  & '0' & x"0B"; -- STA @11  Armazena o valor do acumulador em MEM[11] (dezenas)
tmp(46) := STA  & '1' & x"21"; -- STA @289 Armazena o valor do acumulador em HEX1
tmp(47) := JMP  & '0' & x"18"; -- JMP @24
tmp(48) := NOP  & '0' & x"00"; -- #NOP
------------------------------

--  SUB-rotina soma centenas
tmp(49) := LDI  & '0' & x"00"; -- LDI $0 --  Constante 0
tmp(50) := STA  & '0' & x"0B"; -- STA @11  Armazena o valor do acumulador em MEM[11] (dezenas)
tmp(51) := STA  & '1' & x"21"; -- STA @289 Armazena o valor do acumulador em HEX1

tmp(52) := LDA  & '0' & x"0C"; -- LDA @12   Carrega o acumulador com o valor de MEM[12] (centenas)
tmp(53) := CEQ  & '0' & x"09"; -- CEQ @9   Verifica se o digito é igual a 9
tmp(54) := JEQ  & '0' & x"3C"; -- JEQ @60  Se o digito for igual a 9, pula para SUB-rotina soma centenas

tmp(55) := SOMA & '0' & x"01"; -- SOMA @1  Soma acumulador com valor da MEM[1] (1)
tmp(56) := STA  & '0' & x"0C"; -- STA @12  Armazena o valor do acumulador em MEM[12] (centenas)
tmp(57) := STA  & '1' & x"22"; -- STA @290 Armazena o valor do acumulador em HEX2
tmp(58) := JMP  & '0' & x"18"; -- JMP @24
tmp(59) := NOP  & '0' & x"00"; -- #NOP
------------------------------

tmp(60) := NOP  & '0' & x"00"; -- #NOP
						
        return tmp;
    end initMemory;

    signal memROM : blocoMemoria := initMemory;

begin
    Dado <= memROM (to_integer(unsigned(Endereco)));
end architecture;