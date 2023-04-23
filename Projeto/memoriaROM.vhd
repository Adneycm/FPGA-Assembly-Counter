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

--  ------------------ SETUP --------------------



-- Limpa Displays
tmp(0) := LDI & '0' & x"00";	-- #LDI $0
tmp(1) := STA & '1' & x"20";	-- #STA @288
tmp(2) := STA & '1' & x"21";	-- #STA @289
tmp(3) := STA & '1' & x"22";	-- #STA @290
tmp(4) := STA & '1' & x"23";	-- #STA @291
tmp(5) := STA & '1' & x"24";	-- #STA @292
tmp(6) := STA & '1' & x"25";	-- #STA @293

-- Limpa Leds
tmp(7) := LDI & '0' & x"00";	-- #LDI $0
tmp(8) := STA & '1' & x"00";	-- #STA @256
tmp(9) := STA & '1' & x"01";	-- #STA @257
tmp(10) := STA & '1' & x"02";	-- #STA @258

--  Inicializando posicao de constantes imutáveis
--  Reservado Endereco 0 a 9
tmp(11) := LDI & '0' & x"00";	-- #LDI $0
tmp(12) := STA & '0' & x"00";	-- #STA @0         	--  Constante 0
tmp(13) := LDI & '0' & x"01";	-- #LDI $1         
tmp(14) := STA & '0' & x"01";	-- #STA @1         	--  Constante 1
tmp(15) := LDI & '0' & x"09";	-- #LDI $9
tmp(16) := STA & '0' & x"09";	-- #STA @9         	--  Constante 9  

--  Inicializando posições que guardaram Unidades do contador
--  Reservado Endereco 10 a 19
tmp(17) := LDI & '0' & x"00";	-- #LDI $0
tmp(18) := STA & '0' & x"0A";	-- #STA @10       	--  MEN[10] = Unidades
tmp(19) := STA & '0' & x"0B";	-- #STA @11       	--  MEN[11] = Dezenas
tmp(20) := STA & '0' & x"0C";	-- #STA @12       	--  MEN[12] = Centenas
tmp(21) := STA & '0' & x"0D";	-- #STA @13       	--  MEN[13] = Unidade de Milhar
tmp(22) := STA & '0' & x"0E";	-- #STA @14       	--  MEN[14] = Dezena de Milhar
tmp(23) := STA & '0' & x"0F";	-- #STA @15       	--  MEN[15] = Centena de MIlhar

--  Inicializando posições que guardaram Limite Contador
--  Reservado Endereco 20 a 29
tmp(24) := LDI & '0' & x"00";	-- #LDI $0
tmp(25) := STA & '0' & x"14";	-- #STA @20       	--  MEN[20] = Unidades
tmp(26) := STA & '0' & x"15";	-- #STA @21       	--  MEN[21] = Dezenas
tmp(27) := STA & '0' & x"16";	-- #STA @22       	--  MEN[22] = Centenas
tmp(28) := STA & '0' & x"17";	-- #STA @23       	--  MEN[23] = Unidade de Milhar
tmp(29) := STA & '0' & x"18";	-- #STA @24       	--  MEN[24] = Dezena de Milhar
tmp(30) := STA & '0' & x"19";	-- #STA @25       	--  MEN[25] = Centena de MIlhar

tmp(31) := JMP & '0' & x"97";	-- #JMP @151	--  Pula para Rotina Principal
tmp(32) := NOP & '0' & x"00";	-- #NOP

--  -------------- INCREMENTA CONTADOR ---------------


tmp(33) := STA & '1' & x"FF";	-- #STA @511       	--  Endereco 511 : Limpa Flag FlipFlop KEY0
tmp(34) := LDA & '0' & x"0A";	-- #LDA @10        	--  REGA = Unidade

--  Verifica se valor da unidade é igual a 9:
tmp(35) := CEQ & '0' & x"09";	-- #CEQ @9         	--  Unidade já é = 9?
tmp(36) := JEQ & '0' & x"2D";	-- #JEQ @45	--  SIM : Incrementa dezena
tmp(37) := NOP & '0' & x"00";	-- #NOP
tmp(38) := JEQ & '0' & x"28";	-- #JEQ @40	--  NÃO : Incrementa unidade
tmp(39) := NOP & '0' & x"00";	-- #NOP 

--  ------- Incrementa  Unidade

tmp(40) := SOMA & '0' & x"01";	-- #SOMA @1        	--  REGA = Unidade + 1
tmp(41) := STA & '0' & x"0A";	-- #STA @10        
tmp(42) := STA & '1' & x"20";	-- #STA @288       	--  HEX0 = Unidade
tmp(43) := JMP & '0' & x"6C";	-- #JMP @108	-- JMP .FIM_INCREMENTO
tmp(44) := NOP & '0' & x"00";	-- #NOP

--  ------- Incrementa  Dezena

--  Zera unidade
tmp(45) := LDI & '0' & x"00";	-- #LDI $0
tmp(46) := STA & '0' & x"0A";	-- #STA @10
tmp(47) := STA & '1' & x"20";	-- #STA @288       	--  HEX0 = Unidade

tmp(48) := LDA & '0' & x"0B";	-- #LDA @11        	--  Dezena já é 9 ? 
tmp(49) := CEQ & '0' & x"09";	-- #CEQ @9         
tmp(50) := JEQ & '0' & x"39";	-- #JEQ @57	--  Sim

tmp(51) := LDA & '0' & x"0B";	-- #LDA @11        	--  Carrega dezena
tmp(52) := SOMA & '0' & x"01";	-- #SOMA @1
tmp(53) := STA & '0' & x"0B";	-- #STA @11        
tmp(54) := STA & '1' & x"21";	-- #STA @289       	--  HEX1 = Dezena
tmp(55) := JMP & '0' & x"6C";	-- #JMP @108	-- JMP .FIM_INCREMENTO
tmp(56) := NOP & '0' & x"00";	-- #NOP

--  ------- Incrementa  Centena

--  Zera dezena
tmp(57) := LDI & '0' & x"00";	-- #LDI $0
tmp(58) := STA & '0' & x"0B";	-- #STA @11
tmp(59) := STA & '1' & x"21";	-- #STA @289

tmp(60) := LDA & '0' & x"0C";	-- #LDA @12        	--  Centena já é 9?
tmp(61) := CEQ & '0' & x"09";	-- #CEQ @9
tmp(62) := JEQ & '0' & x"45";	-- #JEQ @69	-- JEQ .UNIDADE_MILHAR

tmp(63) := LDA & '0' & x"0C";	-- #LDA @12        	--  Carrega centena
tmp(64) := SOMA & '0' & x"01";	-- #SOMA @1
tmp(65) := STA & '0' & x"0C";	-- #STA @12        
tmp(66) := STA & '1' & x"22";	-- #STA @290       	--  HEX2 = Centena
tmp(67) := JMP & '0' & x"6C";	-- #JMP @108	-- JMP .FIM_INCREMENTO
tmp(68) := NOP & '0' & x"00";	-- #NOP

--  ------- Incrementa Unidade de Milhar

--  Zera centena
tmp(69) := LDI & '0' & x"00";	-- #LDI $0
tmp(70) := STA & '0' & x"0C";	-- #STA @12
tmp(71) := STA & '1' & x"22";	-- #STA @290

tmp(72) := LDA & '0' & x"0D";	-- #LDA @13        	--  Unidade de milhar já é 9?
tmp(73) := CEQ & '0' & x"09";	-- #CEQ @9
tmp(74) := JEQ & '0' & x"51";	-- #JEQ @81	-- JEQ .DEZENA_MILHAR

tmp(75) := LDA & '0' & x"0D";	-- #LDA @13       	--  Carrega unidade de milhar
tmp(76) := SOMA & '0' & x"01";	-- #SOMA @1
tmp(77) := STA & '0' & x"0D";	-- #STA @13
tmp(78) := STA & '1' & x"23";	-- #STA @291      	--  HEX3 = Unidade de milhar

tmp(79) := JMP & '0' & x"6C";	-- #JMP @108	-- JMP .FIM_INCREMENTO
tmp(80) := NOP & '0' & x"00";	-- #NOP

--  ------- Incrementa Dezena de Milhar

--  Zera unidade de milhar
tmp(81) := LDI & '0' & x"00";	-- #LDI $0
tmp(82) := STA & '0' & x"0D";	-- #STA @13
tmp(83) := STA & '1' & x"23";	-- #STA @291

tmp(84) := LDA & '0' & x"0E";	-- #LDA @14      	--  Dezena de Milhar já é 9?
tmp(85) := CEQ & '0' & x"09";	-- #CEQ @9
tmp(86) := JEQ & '0' & x"5D";	-- #JEQ @93	-- JEQ .CENTENA_MILHAR

tmp(87) := LDA & '0' & x"0E";	-- #LDA @14       	--  Carrega dezena de milhar
tmp(88) := SOMA & '0' & x"01";	-- #SOMA @1
tmp(89) := STA & '0' & x"0E";	-- #STA @14
tmp(90) := STA & '1' & x"24";	-- #STA @292      	--  HEX4 = Unidade de milhar

tmp(91) := JMP & '0' & x"6C";	-- #JMP @108	-- JMP .FIM_INCREMENTO
tmp(92) := NOP & '0' & x"00";	-- #NOP

--  ------- Incrementa Centena de Milhar

--  Zera dezena de milhar
tmp(93) := LDI & '0' & x"00";	-- #LDI $0
tmp(94) := STA & '0' & x"0E";	-- #STA @14
tmp(95) := STA & '1' & x"24";	-- #STA @292

tmp(96) := LDA & '0' & x"0F";	-- #LDA @15      	--  Centena de Milhar já é 9?
tmp(97) := CEQ & '0' & x"09";	-- #CEQ @9
tmp(98) := JEQ & '0' & x"69";	-- #JEQ @105	-- JEQ .ZERA_CENTENA_MILHAR

tmp(99) := LDA & '0' & x"0F";	-- #LDA @15       	--  Carrega dezena de milhar
tmp(100) := SOMA & '0' & x"01";	-- #SOMA @1
tmp(101) := STA & '0' & x"0F";	-- #STA @15
tmp(102) := STA & '1' & x"25";	-- #STA @293      	--  HEX5 = Centena de milhar

tmp(103) := JMP & '0' & x"6C";	-- #JMP @108	-- JMP .FIM_INCREMENTO
tmp(104) := NOP & '0' & x"00";	-- #NOP

-- Zera centena de milhar

tmp(105) := LDI & '0' & x"00";	-- #LDI $0
tmp(106) := STA & '0' & x"0F";	-- #STA @15
tmp(107) := STA & '1' & x"25";	-- #STA @293

--  ------- FIM INCREMENTO

tmp(108) := JMP & '0' & x"97";	-- #JMP @151	-- JMP .MAIN
tmp(109) := NOP & '0' & x"00";	-- #NOP

--  --------------- LIMPA LIMITE    ----------------


-- Limpa Displays
tmp(110) := LDI & '0' & x"00";	-- #LDI $0
tmp(111) := STA & '1' & x"20";	-- #STA @288
tmp(112) := STA & '1' & x"21";	-- #STA @289
tmp(113) := STA & '1' & x"22";	-- #STA @290
tmp(114) := STA & '1' & x"23";	-- #STA @291
tmp(115) := STA & '1' & x"24";	-- #STA @292
tmp(116) := STA & '1' & x"25";	-- #STA @293

--  Limpa valores guardados no contador
tmp(117) := LDI & '0' & x"00";	-- #LDI $0
tmp(118) := STA & '0' & x"0A";	-- #STA @10       	--  MEN[10] = Unidades
tmp(119) := STA & '0' & x"0B";	-- #STA @11       	--  MEN[11] = Dezenas
tmp(120) := STA & '0' & x"0C";	-- #STA @12       	--  MEN[12] = Centenas
tmp(121) := STA & '0' & x"0D";	-- #STA @13       	--  MEN[13] = Unidade de Milhar
tmp(122) := STA & '0' & x"0E";	-- #STA @14       	--  MEN[14] = Dezena de Milhar
tmp(123) := STA & '0' & x"0F";	-- #STA @15       	--  MEN[15] = Centena de MIlhar

tmp(124) := JMP & '0' & x"84";	-- #JMP @132	-- JMP .SET_UNIDADE

--  --------------- LIMITE CONTADOR ----------------


tmp(125) := LDI & '0' & x"01";	-- #LDI $1
tmp(126) := STA & '1' & x"02";	-- #STA @258                      	--  Indicativo de que esse modo foi selecionado. LEDR9

tmp(127) := LDA & '1' & x"42";	-- #LDA @322                      
tmp(128) := CEQ & '0' & x"00";	-- #CEQ @0
tmp(129) := JEQ & '0' & x"93";	-- #JEQ @147	--  Deseleciona Modo : FIM_LIMITE_CONTADOR
tmp(130) := NOP & '0' & x"00";	-- #NOP

--  Limpa posições de memoria e displays
tmp(131) := JMP & '0' & x"6E";	-- #JMP @110	-- JMP .LIMPA_LIMITE 

--  Seta valor Unidade

tmp(132) := LDI & '0' & x"01";	-- #LDI $1
tmp(133) := STA & '1' & x"00";	-- #STA @256                     	--  LEDR1 -> Indicativo limite Unidade

tmp(134) := LDA & '1' & x"40";	-- #LDA @320                     	--  Lê chaves
tmp(135) := STA & '0' & x"14";	-- #STA @20                      	--  Salva valor limite unidade em MEN[20]
tmp(136) := STA & '1' & x"20";	-- #STA @288                     	--  HEX0 = Valor da unidade setado

tmp(137) := LDA & '1' & x"61";	-- #LDA @353                     	--  Observa KEY1 ->  (1 -> Seta Dezena  ; 0 -> Seta Unidade) 
tmp(138) := CEQ & '0' & x"01";	-- #CEQ @1 
tmp(139) := JEQ & '0' & x"8F";	-- #JEQ @143	-- JEQ .SET_DEZENA
tmp(140) := NOP & '0' & x"00";	-- #NOP
tmp(141) := JMP & '0' & x"84";	-- #JMP @132	-- JMP .SET_UNIDADE
tmp(142) := NOP & '0' & x"00";	-- #NOP

--  Seta valor unidade

tmp(143) := LDI & '0' & x"02";	-- #LDI $2
tmp(144) := STA & '1' & x"00";	-- #STA @256                     	--  LEDR2 -> Indicativo limite Dezena

tmp(145) := JMP & '0' & x"7D";	-- #JMP @125	-- JMP .LIMITE_CONTADOR
tmp(146) := NOP & '0' & x"00";	-- #NOP

--  Desativa modo Limite Contador

tmp(147) := LDI & '0' & x"00";	-- #LDI $0                        	--  LEDR9 = 0
tmp(148) := STA & '1' & x"02";	-- #STA @258 
tmp(149) := JMP & '0' & x"97";	-- #JMP @151	-- JMP .MAIN
tmp(150) := NOP & '0' & x"00";	-- #NOP

--  -------------- ROTINA PRINCIPAL -----------------


tmp(151) := LDA & '1' & x"60";	-- #LDA @352                      	--  Lê KEY0 
tmp(152) := CEQ & '0' & x"01";	-- #CEQ @1                        
tmp(153) := JEQ & '0' & x"21";	-- #JEQ @33	--  APERTADO
tmp(154) := NOP & '0' & x"00";	-- #NOP
tmp(155) := LDA & '1' & x"42";	-- #LDA @322                      	--  Lê chave SW9 -> Limite de Incremento
tmp(156) := CEQ & '0' & x"01";	-- #CEQ @1                           
tmp(157) := JEQ & '0' & x"7D";	-- #JEQ @125	--  Modo de inserir limite selecionado
tmp(158) := NOP & '0' & x"00";	-- #NOP
tmp(159) := JMP & '0' & x"97";	-- #JMP @151	-- JMP .MAIN
tmp(160) := NOP & '0' & x"00";	-- #NOP

        return tmp;
    end initMemory;

    signal memROM : blocoMemoria := initMemory;

begin
    Dado <= memROM (to_integer(unsigned(Endereco)));
end architecture;