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
  constant OP_AND : std_logic_vector(3 downto 0) := "1011";
  
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

--  Inicializando posições que guardaram limites de Unidades do contador
tmp(24) := LDI & '0' & x"00";	-- #LDI $0
tmp(25) := STA & '0' & x"14";	-- #STA @20       	--  MEN[20] = limite Unidades
tmp(26) := STA & '0' & x"15";	-- #STA @21       	--  MEN[21] = limite Dezenas
tmp(27) := STA & '0' & x"16";	-- #STA @22       	--  MEN[22] = limite Centenas
tmp(28) := STA & '0' & x"17";	-- #STA @23       	--  MEN[23] = limite Unidade de Milhar
tmp(29) := STA & '0' & x"18";	-- #STA @24       	--  MEN[24] = limite Centena de Milhar
tmp(30) := STA & '0' & x"19";	-- #STA @25       	--  MEN[25] = limite Unidade de Milhão


-- Leitura do limite de contagem unidade
tmp(31) := LDI & '0' & x"01";	-- LDI $1
tmp(32) := STA & '1' & x"00"; -- STA @256 -- Acende LEDR0


tmp(33) := LDA & '1' & x"40"; -- LDA @320  -- Faz a leitura das chaves SW7~SW0
tmp(34) := STA & '0' & x"14"; -- STA @20   -- Guarda valor em limite de unidades
tmp(35) := LDA & '1' & x"61";	-- LDA @353  -- Carrega o acumulador com a leitura do botão KEY1
tmp(36) := OP_AND & '0' & x"01"; -- LIMPA LIXO KEY1
tmp(37) := CEQ & '0' & x"01";	-- CEQ @1    -- Compara com valor armazenado em MEM[1]
tmp(38) := JEQ & '0' & x"29";	-- JEQ @41   -- Pula para SUB-rotina limite dezenas
tmp(39) := NOP & '0' & x"00"; -- NOP
tmp(40) := JMP & '0' & x"21";	-- JMP @33 


-- Leitura do limite de contagem dezena
tmp(41) := STA & '1' & x"FE"; -- Limpa flipflop KEY1

tmp(42) := LDI & '0' & x"00";	-- LDI $0
tmp(42) := STA & '1' & x"00"; -- STA @256 -- Apaga LEDs

tmp(43) := LDI & '0' & x"02";	-- LDI $2
tmp(44) := STA & '1' & x"00"; -- STA @256 -- Acende LEDR1


tmp(45) := LDA & '1' & x"40"; -- LDA @320  -- Faz a leitura das chaves SW7~SW0
tmp(46) := STA & '0' & x"15"; -- STA @21   -- Guarda valor em limite de dezenas
tmp(47) := LDA & '1' & x"61";	-- LDA @353  -- Carrega o acumulador com a leitura do botão KEY1
tmp(48) := OP_AND & '0' & x"01"; -- LIMPA LIXO KEY1
tmp(49) := CEQ & '0' & x"01";	-- CEQ @1    -- Compara com valor armazenado em MEM[1]
tmp(50) := JEQ & '0' & x"35";	-- JEQ @53   -- Pula para SUB-rotina limite cetenas
tmp(51) := NOP & '0' & x"00"; -- NOP
tmp(52) := JMP & '0' & x"2D";	-- JMP @45

-- Leitura do limite de contagem centena
tmp(53) := STA & '1' & x"FE"; -- Limpa flipflop KEY1

tmp(54) := LDI & '0' & x"00"; -- LDI $0
tmp(55) := STA & '1' & x"00"; -- STA @256 -- Apaga LEDs

tmp(56) := LDI & '0' & x"04"; -- LDI $4
tmp(57) := STA & '1' & x"00"; -- STA @256 -- Acende LEDR2


tmp(58) := LDA & '1' & x"40"; -- LDA @320  -- Faz a leitura das chaves SW7~SW0
tmp(59) := STA & '0' & x"16"; -- STA @22   -- Guarda valor em limite de centena
tmp(60) := LDA & '1' & x"61"; -- LDA @353  -- Carrega o acumulador com a leitura do botão KEY1
tmp(61) := OP_AND & '0' & x"01"; -- LIMPA LIXO KEY1
tmp(62) := CEQ & '0' & x"01"; -- CEQ @1    -- Compara com valor armazenado em MEM[1]
tmp(63) := JEQ & '0' & x"42"; -- JEQ @66   -- Pula para iniciar lógica do contador
tmp(64) := NOP & '0' & x"00"; -- NOP
tmp(65) := JMP & '0' & x"3A"; -- JMP @58


tmp(66) := NOP & '0' & x"00"; -- NOP
tmp(67) := LDI & '0' & x"00";	-- LDI $0
tmp(68) := STA & '1' & x"00"; -- STA @256 -- Apaga LEDs


--  LÓGICA DO CONTADOR
tmp(69) := LDA & '1' & x"60"; -- LDA @352 Carrega o acumulador com a leitura do botão KEY0
tmp(70) := OP_AND & '0' & x"01"; -- LIMPA LIXO KEY0
tmp(71) := CEQ & '0' & x"01"; -- CEQ @1   Compara com valor armazenado em MEM[1]
tmp(72) := JEQ & '0' & x"50"; -- JEQ @80  Pula para SUB-rotina soma unidades
tmp(73) := NOP & '0' & x"00"; -- NOP

tmp(74) := LDA & '1' & x"64"; -- LDA @356 Carrega o acumulador com a leitura do botão FPGA_RESET
tmp(75) := OP_AND & '0' & x"01"; -- LIMPA LIXO FPGA_RESET
tmp(76) := CEQ & '0' & x"00"; -- CEQ @0   Compara com valor armazenado em MEM[0]
tmp(77) := JEQ & '0' & x"72"; -- JEQ @114  Pula para SUB-rotina reset
tmp(78) := NOP & '0' & x"00"; -- NOP

tmp(79) := JMP & '0' & x"45"; -- JMP @69



--  SUB-rotina soma unidades
tmp(80) := STA & '1' & x"FF"; -- Limpa flipflop KEY0
tmp(81) := LDA & '0' & x"0A"; -- LDA @10   Carrega o acumulador com o valor de MEM[10] (unidades)

tmp(82) := CEQ & '0' & x"09"; -- CEQ @9   Verifica se o digito é igual a 9
tmp(83) := JEQ & '0' & x"5C"; -- JEQ @92  Se o digito for igual a 9, pula para SUB-rotina soma dezenas

tmp(84) := CEQ & '0' & x"14"; -- CEQ @20 Compara com valor limite de unidade MEM[20]
tmp(85) := JEQ & '0' & x"7C"; -- JEQ @124 Pula para sub-rotina de limite de contagem

tmp(86) := LDA & '0' & x"0A"; -- LDA @10   Carrega o acumulador com o valor de MEM[10] (unidades)
tmp(87) := SOMA & '0' & x"01"; -- SOMA @1  Soma acumulador com valor da MEM[1] (1)
tmp(88) := STA  & '0' & x"0A"; -- STA @10  Armazena o valor do acumulador em MEM[10] (unidades)
tmp(89) := STA  & '1' & x"20"; -- STA @288 Armazena o valor do acumulador em HEX0
tmp(90) := JMP & '0' & x"45"; -- JMP @69
tmp(91) := NOP  & '0' & x"00"; -- #NOP
------------------------------

--  SUB-rotina soma dezenas
tmp(92) := LDI  & '0' & x"00"; -- LDI $0 --  Constante 0
tmp(93) := STA  & '0' & x"0A"; -- STA @10  Armazena o valor do acumulador em MEM[10] (unidades)
tmp(94) := STA  & '1' & x"20"; -- STA @288 Armazena o valor do acumulador em HEX0

tmp(95) := LDA  & '0' & x"0B"; -- LDA @11   Carrega o acumulador com o valor de MEM[11] (dezenas)
tmp(96) := CEQ  & '0' & x"09"; -- CEQ @9   Verifica se o digito é igual a 9
tmp(97) := JEQ  & '0' & x"67"; -- JEQ @103  Se o digito for igual a 9, pula para SUB-rotina soma centenas

tmp(98) := SOMA & '0' & x"01"; -- SOMA @1  Soma acumulador com valor da MEM[1] (1)
tmp(99) := STA  & '0' & x"0B"; -- STA @11  Armazena o valor do acumulador em MEM[11] (dezenas)
tmp(100) := STA  & '1' & x"21"; -- STA @289 Armazena o valor do acumulador em HEX1
tmp(101) := JMP & '0' & x"45"; -- JMP @69
tmp(102) := NOP  & '0' & x"00"; -- #NOP
------------------------------

--  SUB-rotina soma centenas
tmp(103) := LDI  & '0' & x"00"; -- LDI $0 --  Constante 0
tmp(104) := STA  & '0' & x"0B"; -- STA @11  Armazena o valor do acumulador em MEM[11] (dezenas)
tmp(105) := STA  & '1' & x"21"; -- STA @289 Armazena o valor do acumulador em HEX1

tmp(106)  := LDA  & '0' & x"0C"; -- LDA @12   Carrega o acumulador com o valor de MEM[12] (centenas)
tmp(107) := CEQ  & '0' & x"09"; -- CEQ @9   Verifica se o digito é igual a 9
tmp(108) := JEQ  & '0' & x"3C"; -- JEQ @60  Se o digito for igual a 9, pula para SUB-rotina soma centenas

tmp(109) := SOMA & '0' & x"01"; -- SOMA @1  Soma acumulador com valor da MEM[1] (1)
tmp(110) := STA  & '0' & x"0C"; -- STA @12  Armazena o valor do acumulador em MEM[12] (centenas)
tmp(111) := STA  & '1' & x"22"; -- STA @290 Armazena o valor do acumulador em HEX2
tmp(112) := JMP & '0' & x"45"; -- JMP @69
tmp(113) := NOP  & '0' & x"00"; -- #NOP
------------------------------

--  SUB-rotina reset
tmp(114) := LDI  & '0' & x"00"; -- LDI $0 --  Constante 0

tmp(115) := STA  & '0' & x"0A"; -- STA @10  Armazena o valor do acumulador em MEM[10] (unidades)
tmp(116) := STA  & '1' & x"20"; -- STA @288 Armazena o valor do acumulador em HEX0

tmp(117) := STA  & '0' & x"0B"; -- STA @11  Armazena o valor do acumulador em MEM[11] (dezenas)
tmp(118) := STA  & '1' & x"21"; -- STA @289 Armazena o valor do acumulador em HEX1

tmp(119) := STA  & '0' & x"0C"; -- STA @12  Armazena o valor do acumulador em MEM[12] (centenas)
tmp(120) := STA  & '1' & x"22"; -- STA @290 Armazena o valor do acumulador em HEX2

tmp(121) := JMP & '0' & x"45"; -- JMP @69
tmp(122) := NOP  & '0' & x"00"; -- #NOP
------------------------------

tmp(123) := NOP  & '0' & x"00"; -- #NOP

-- SUB-rotina limite contagem
tmp(124) := LDA & '0' & x"0B"; -- LDA @11   Carrega o acumulador com o valor de MEM[11] (dezenas)
tmp(125) := CEQ & '0' & x"15"; -- CEQ @21 Compara com valor limite de dezena MEM[21]
tmp(126) := JEQ & '0' & x"81"; -- JEQ @129 Pula para sub-rotina de limite de contagem centena
tmp(127) := NOP & '0' & x"00"; -- #NOP
tmp(128) := JMP & '0' & x"56"; -- JMP @86 retorna para soma normal

tmp(129) := LDA & '0' & x"0C"; -- LDA @12   Carrega o acumulador com o valor de MEM[12] (centenas)
tmp(130) := CEQ & '0' & x"16"; -- CEQ @22 Compara com valor limite de centena MEM[22]
tmp(131) := JEQ & '0' & x"86"; -- JEQ @134 Pula para SUB-rotina overflow de limite
tmp(132) := NOP & '0' & x"00"; -- #NOP
tmp(133) := JMP & '0' & x"56"; -- JMP @86 retorna para soma normal
------------------------------


--  SUB-rotina over flow

--  Acendendo os LEDs
tmp(134)  := LDI & '0' & x"01"; -- LDI $1
tmp(135)  := STA & '1' & x"01"; -- STA @257 LDR8
tmp(136) := STA & '1' & x"02";  -- STA @258 LDR9

tmp(137) := LDI & '0' & x"FF"; -- LDI $255
tmp(138)  := STA & '1' & x"00"; -- STA @257 LDR0~LEDR7

tmp(139) := LDA & '1' & x"64"; -- LDA @356 Carrega o acumulador com a leitura do botão FPGA_RESET
tmp(140) := OP_AND & '0' & x"01"; -- LIMPA LIXO FPGA_RESET
tmp(141) := CEQ & '0' & x"00"; -- CEQ @0   Compara com valor armazenado em MEM[0]
tmp(142) := JEQ & '0' & x"72"; -- JEQ @114  Pula para SUB-rotina reset
tmp(143) := NOP & '0' & x"00"; -- NOP

tmp(144) := JMP & '0' & x"8B"; -- JMP @139
						
        return tmp;
    end initMemory;

    signal memROM : blocoMemoria := initMemory;

begin
    Dado <= memROM (to_integer(unsigned(Endereco)));
end architecture;