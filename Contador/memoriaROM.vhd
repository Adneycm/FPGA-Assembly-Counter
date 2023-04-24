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
--  Caso limite contador nao seja selecionado, utilizar o valor padrao 999999
tmp(24) := LDI & '0' & x"09";	-- #LDI $9
tmp(25) := STA & '0' & x"14";	-- #STA @20       	--  MEN[20] = Unidades
tmp(26) := STA & '0' & x"15";	-- #STA @21       	--  MEN[21] = Dezenas
tmp(27) := STA & '0' & x"16";	-- #STA @22       	--  MEN[22] = Centenas
tmp(28) := STA & '0' & x"17";	-- #STA @23       	--  MEN[23] = Unidade de Milhar
tmp(29) := STA & '0' & x"18";	-- #STA @24       	--  MEN[24] = Dezena de Milhar
tmp(30) := STA & '0' & x"19";	-- #STA @25       	--  MEN[25] = Centena de MIlhar

tmp(31) := JMP & '1' & x"11";	-- #JMP @273	--  Pula para Rotina Principal
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

tmp(43) := JMP & '0' & x"71";	-- #JMP @113	--  Verifica Overflow
tmp(44) := NOP & '0' & x"00";	-- #NOP

--  ------- Incrementa  Dezena

--  Zera unidade
tmp(45) := LDI & '0' & x"00";	-- #LDI $0
tmp(46) := STA & '0' & x"0A";	-- #STA @10
tmp(47) := STA & '1' & x"20";	-- #STA @288       	--  HEX0 = Unidade

tmp(48) := LDA & '0' & x"0B";	-- #LDA @11        	--  Dezena já é 9 ? 
tmp(49) := CEQ & '0' & x"09";	-- #CEQ @9         
tmp(50) := JEQ & '0' & x"3A";	-- #JEQ @58	--  Sim
tmp(51) := NOP & '0' & x"00";	-- #NOP

tmp(52) := LDA & '0' & x"0B";	-- #LDA @11        	--  Carrega dezena
tmp(53) := SOMA & '0' & x"01";	-- #SOMA @1
tmp(54) := STA & '0' & x"0B";	-- #STA @11        
tmp(55) := STA & '1' & x"21";	-- #STA @289       	--  HEX1 = Dezena

tmp(56) := JMP & '0' & x"71";	-- #JMP @113	--  Verifica Overflow
tmp(57) := NOP & '0' & x"00";	-- #NOP

--  ------- Incrementa  Centena

--  Zera dezena
tmp(58) := LDI & '0' & x"00";	-- #LDI $0
tmp(59) := STA & '0' & x"0B";	-- #STA @11
tmp(60) := STA & '1' & x"21";	-- #STA @289

tmp(61) := LDA & '0' & x"0C";	-- #LDA @12        	--  Centena já é 9?
tmp(62) := CEQ & '0' & x"09";	-- #CEQ @9
tmp(63) := JEQ & '0' & x"47";	-- #JEQ @71	-- JEQ .UNIDADE_MILHAR
tmp(64) := NOP & '0' & x"00";	-- #NOP

tmp(65) := LDA & '0' & x"0C";	-- #LDA @12        	--  Carrega centena
tmp(66) := SOMA & '0' & x"01";	-- #SOMA @1
tmp(67) := STA & '0' & x"0C";	-- #STA @12        
tmp(68) := STA & '1' & x"22";	-- #STA @290       	--  HEX2 = Centena

tmp(69) := JMP & '0' & x"71";	-- #JMP @113	--  Verifica Overflow
tmp(70) := NOP & '0' & x"00";	-- #NOP

--  ------- Incrementa Unidade de Milhar

--  Zera centena
tmp(71) := LDI & '0' & x"00";	-- #LDI $0
tmp(72) := STA & '0' & x"0C";	-- #STA @12
tmp(73) := STA & '1' & x"22";	-- #STA @290

tmp(74) := LDA & '0' & x"0D";	-- #LDA @13        	--  Unidade de milhar já é 9?
tmp(75) := CEQ & '0' & x"09";	-- #CEQ @9
tmp(76) := JEQ & '0' & x"54";	-- #JEQ @84	-- JEQ .DEZENA_MILHAR
tmp(77) := NOP & '0' & x"00";	-- #NOP

tmp(78) := LDA & '0' & x"0D";	-- #LDA @13       	--  Carrega unidade de milhar
tmp(79) := SOMA & '0' & x"01";	-- #SOMA @1
tmp(80) := STA & '0' & x"0D";	-- #STA @13
tmp(81) := STA & '1' & x"23";	-- #STA @291      	--  HEX3 = Unidade de milhar

tmp(82) := JMP & '0' & x"71";	-- #JMP @113	--  Verifica Overflow
tmp(83) := NOP & '0' & x"00";	-- #NOP

--  ------- Incrementa Dezena de Milhar

--  Zera unidade de milhar
tmp(84) := LDI & '0' & x"00";	-- #LDI $0
tmp(85) := STA & '0' & x"0D";	-- #STA @13
tmp(86) := STA & '1' & x"23";	-- #STA @291

tmp(87) := LDA & '0' & x"0E";	-- #LDA @14      	--  Dezena de Milhar já é 9?
tmp(88) := CEQ & '0' & x"09";	-- #CEQ @9
tmp(89) := JEQ & '0' & x"61";	-- #JEQ @97	-- JEQ .CENTENA_MILHAR
tmp(90) := NOP & '0' & x"00";	-- #NOP

tmp(91) := LDA & '0' & x"0E";	-- #LDA @14       	--  Carrega dezena de milhar
tmp(92) := SOMA & '0' & x"01";	-- #SOMA @1
tmp(93) := STA & '0' & x"0E";	-- #STA @14
tmp(94) := STA & '1' & x"24";	-- #STA @292      	--  HEX4 = Unidade de milhar

tmp(95) := JMP & '0' & x"71";	-- #JMP @113	--  Verifica Overflow
tmp(96) := NOP & '0' & x"00";	-- #NOP

--  ------- Incrementa Centena de Milhar

--  Zera dezena de milhar
tmp(97) := LDI & '0' & x"00";	-- #LDI $0
tmp(98) := STA & '0' & x"0E";	-- #STA @14
tmp(99) := STA & '1' & x"24";	-- #STA @292

tmp(100) := LDA & '0' & x"0F";	-- #LDA @15      	--  Centena de Milhar já é 9?
tmp(101) := CEQ & '0' & x"09";	-- #CEQ @9
tmp(102) := JEQ & '0' & x"6E";	-- #JEQ @110	-- JEQ .ZERA_CENTENA_MILHAR
tmp(103) := NOP & '0' & x"00";	-- #NOP

tmp(104) := LDA & '0' & x"0F";	-- #LDA @15       	--  Carrega dezena de milhar
tmp(105) := SOMA & '0' & x"01";	-- #SOMA @1
tmp(106) := STA & '0' & x"0F";	-- #STA @15
tmp(107) := STA & '1' & x"25";	-- #STA @293      	--  HEX5 = Centena de milhar

tmp(108) := JMP & '0' & x"71";	-- #JMP @113	--  Verifica Overflow
tmp(109) := NOP & '0' & x"00";	-- #NOP

-- Zera centena de milhar

tmp(110) := LDI & '0' & x"00";	-- #LDI $0
tmp(111) := STA & '0' & x"0F";	-- #STA @15
tmp(112) := STA & '1' & x"25";	-- #STA @293

--  ------- VERIFICA OVERFLOW


--  Compara unidade
tmp(113) := LDA & '0' & x"0A";	-- #LDA @10                  
tmp(114) := CEQ & '0' & x"14";	-- #CEQ @20
tmp(115) := JEQ & '0' & x"77";	-- #JEQ @119	-- JEQ .COMPARA_DEZENA
tmp(116) := NOP & '0' & x"00";	-- #NOP
tmp(117) := JMP & '0' & x"A1";	-- #JMP @161	-- JMP .FIM_INCREMENTO
tmp(118) := NOP & '0' & x"00";	-- #NOP

--  Compara dezena

tmp(119) := LDA & '0' & x"0B";	-- #LDA @11                  
tmp(120) := CEQ & '0' & x"15";	-- #CEQ @21
tmp(121) := JEQ & '0' & x"7D";	-- #JEQ @125	-- JEQ .COMPARA_CENTENA
tmp(122) := NOP & '0' & x"00";	-- #NOP
tmp(123) := JMP & '0' & x"A1";	-- #JMP @161	-- JMP .FIM_INCREMENTO
tmp(124) := NOP & '0' & x"00";	-- #NOP

--  Compara centena

tmp(125) := LDA & '0' & x"0C";	-- #LDA @12                  
tmp(126) := CEQ & '0' & x"16";	-- #CEQ @22
tmp(127) := JEQ & '0' & x"83";	-- #JEQ @131	-- JEQ .COMPARA_UNIDADE_MILHAR
tmp(128) := NOP & '0' & x"00";	-- #NOP
tmp(129) := JMP & '0' & x"A1";	-- #JMP @161	-- JMP .FIM_INCREMENTO
tmp(130) := NOP & '0' & x"00";	-- #NOP

--  Compara unidade de milhar

tmp(131) := LDA & '0' & x"0D";	-- #LDA @13                  
tmp(132) := CEQ & '0' & x"17";	-- #CEQ @23
tmp(133) := JEQ & '0' & x"89";	-- #JEQ @137	-- JEQ .COMPARA_DEZENA_MILHAR
tmp(134) := NOP & '0' & x"00";	-- #NOP
tmp(135) := JMP & '0' & x"A1";	-- #JMP @161	-- JMP .FIM_INCREMENTO
tmp(136) := NOP & '0' & x"00";	-- #NOP

--  Compara dezena de milhar

tmp(137) := LDA & '0' & x"0E";	-- #LDA @14                  
tmp(138) := CEQ & '0' & x"18";	-- #CEQ @24
tmp(139) := JEQ & '0' & x"8F";	-- #JEQ @143	-- JEQ .COMPARA_CENTENA_MILHAR
tmp(140) := NOP & '0' & x"00";	-- #NOP
tmp(141) := JMP & '0' & x"A1";	-- #JMP @161	-- JMP .FIM_INCREMENTO
tmp(142) := NOP & '0' & x"00";	-- #NOP

--  Compara centena de milhar

tmp(143) := LDA & '0' & x"0E";	-- #LDA @14                  
tmp(144) := CEQ & '0' & x"18";	-- #CEQ @24
tmp(145) := JEQ & '0' & x"95";	-- #JEQ @149	-- JEQ .INDICA_OVERFLOW
tmp(146) := NOP & '0' & x"00";	-- #NOP
tmp(147) := JMP & '0' & x"A1";	-- #JMP @161	-- JMP .FIM_INCREMENTO
tmp(148) := NOP & '0' & x"00";	-- #NOP

--  ------- Indicativos visuais de overflow


-- Acende todos os leds
tmp(149) := LDI & '0' & x"FF";	-- #LDI $255
tmp(150) := STA & '1' & x"00";	-- #STA @256
tmp(151) := LDI & '0' & x"01";	-- #LDI $1
tmp(152) := STA & '1' & x"01";	-- #STA @257
tmp(153) := STA & '1' & x"02";	-- #STA @258

-- Limpa Displays
tmp(154) := LDI & '0' & x"00";	-- #LDI $0
tmp(155) := STA & '1' & x"20";	-- #STA @288
tmp(156) := STA & '1' & x"21";	-- #STA @289
tmp(157) := STA & '1' & x"22";	-- #STA @290
tmp(158) := STA & '1' & x"23";	-- #STA @291
tmp(159) := STA & '1' & x"24";	-- #STA @292
tmp(160) := STA & '1' & x"25";	-- #STA @293

--  ------- FIM INCREMENTO

tmp(161) := JMP & '1' & x"11";	-- #JMP @273	-- JMP .MAIN
tmp(162) := NOP & '0' & x"00";	-- #NOP

--  --------------- LIMPA LIMITE    ----------------


-- Limpa Displays
tmp(163) := LDI & '0' & x"00";	-- #LDI $0
tmp(164) := STA & '1' & x"20";	-- #STA @288
tmp(165) := STA & '1' & x"21";	-- #STA @289
tmp(166) := STA & '1' & x"22";	-- #STA @290
tmp(167) := STA & '1' & x"23";	-- #STA @291
tmp(168) := STA & '1' & x"24";	-- #STA @292
tmp(169) := STA & '1' & x"25";	-- #STA @293

--  Limpa valores guardados no contador
tmp(170) := LDI & '0' & x"00";	-- #LDI $0
tmp(171) := STA & '0' & x"0A";	-- #STA @10       	--  MEN[10] = Unidades
tmp(172) := STA & '0' & x"0B";	-- #STA @11       	--  MEN[11] = Dezenas
tmp(173) := STA & '0' & x"0C";	-- #STA @12       	--  MEN[12] = Centenas
tmp(174) := STA & '0' & x"0D";	-- #STA @13       	--  MEN[13] = Unidade de Milhar
tmp(175) := STA & '0' & x"0E";	-- #STA @14       	--  MEN[14] = Dezena de Milhar
tmp(176) := STA & '0' & x"0F";	-- #STA @15       	--  MEN[15] = Centena de MIlhar

tmp(177) := JMP & '0' & x"B5";	-- #JMP @181	-- JMP .SET_UNIDADE

--  --------------- LIMITE CONTADOR ----------------


tmp(178) := LDI & '0' & x"01";	-- #LDI $1
tmp(179) := STA & '1' & x"02";	-- #STA @258                      	--  Indicativo de que esse modo foi selecionado. LEDR9

--  Limpa posições de memoria e displays
tmp(180) := JMP & '0' & x"A3";	-- #JMP @163	-- JMP .LIMPA_LIMITE 

--  ------ Seta valor Unidade


tmp(181) := LDI & '0' & x"01";	-- #LDI $1
tmp(182) := STA & '1' & x"00";	-- #STA @256                     	--  LEDR1 -> Indicativo limite Unidade

tmp(183) := LDA & '1' & x"40";	-- #LDA @320                     	--  Lê chaves
tmp(184) := STA & '0' & x"14";	-- #STA @20                      	--  Salva valor limite unidade em MEN[20]
tmp(185) := STA & '1' & x"20";	-- #STA @288                     	--  HEX0 = Valor da unidade setado

tmp(186) := LDA & '1' & x"61";	-- #LDA @353                     	--  Observa KEY1 ->  (1 -> Seta Dezena  ; 0 -> Seta Unidade) 
tmp(187) := OP_AND & '0' & x"01";	-- #OP_AND @1 
tmp(188) := CEQ & '0' & x"01";	-- #CEQ @1 
tmp(189) := JEQ & '0' & x"C1";	-- #JEQ @193	-- JEQ .SET_DEZENA
tmp(190) := NOP & '0' & x"00";	-- #NOP
tmp(191) := JMP & '0' & x"B5";	-- #JMP @181	-- JMP .SET_UNIDADE
tmp(192) := NOP & '0' & x"00";	-- #NOP

--  ------ Seta valor Dezena


tmp(193) := STA & '1' & x"FE";	-- #STA @510                     	--  Limpa KEY1

tmp(194) := LDI & '0' & x"02";	-- #LDI $2
tmp(195) := STA & '1' & x"00";	-- #STA @256                     	--  LEDR2 -> Indicativo limite Dezena

tmp(196) := LDA & '1' & x"40";	-- #LDA @320                     	--  Lê chaves
tmp(197) := STA & '0' & x"15";	-- #STA @21                      	--  Salva valor limite dezena em MEN[21]
tmp(198) := STA & '1' & x"21";	-- #STA @289                     	--  HEX1 = Valor da dezena setado

tmp(199) := LDA & '1' & x"61";	-- #LDA @353                     	--  Observa KEY1 ->  (1 -> Seta Centena  ; 0 -> Seta Dezena) 
tmp(200) := OP_AND & '0' & x"01";	-- #OP_AND @1 
tmp(201) := CEQ & '0' & x"01";	-- #CEQ @1 
tmp(202) := JEQ & '0' & x"CE";	-- #JEQ @206	-- JEQ .SET_CENTENA
tmp(203) := NOP & '0' & x"00";	-- #NOP
tmp(204) := JMP & '0' & x"C1";	-- #JMP @193	-- JMP .SET_DEZENA
tmp(205) := NOP & '0' & x"00";	-- #NOP

--  ------ Seta valor Centena


tmp(206) := STA & '1' & x"FE";	-- #STA @510                     	--  Limpa KEY1

tmp(207) := LDI & '0' & x"04";	-- #LDI $4
tmp(208) := STA & '1' & x"00";	-- #STA @256                     	--  LEDR3 -> Indicativo limite Centena

tmp(209) := LDA & '1' & x"40";	-- #LDA @320                     	--  Lê chaves
tmp(210) := STA & '0' & x"16";	-- #STA @22                      	--  Salva valor limite centena em MEN[22]
tmp(211) := STA & '1' & x"22";	-- #STA @290                     	--  HEX2 = Valor da dezena setado

tmp(212) := LDA & '1' & x"61";	-- #LDA @353                     	--  Observa KEY1 ->  (1 -> Seta Unidade Milhar  ; 0 -> Seta Centena)
tmp(213) := OP_AND & '0' & x"01";	-- #OP_AND @1  
tmp(214) := CEQ & '0' & x"01";	-- #CEQ @1 
tmp(215) := JEQ & '0' & x"DB";	-- #JEQ @219	-- JEQ .SET_UNIDADE_MILHAR
tmp(216) := NOP & '0' & x"00";	-- #NOP
tmp(217) := JMP & '0' & x"CE";	-- #JMP @206	-- JMP .SET_CENTENA
tmp(218) := NOP & '0' & x"00";	-- #NOP

--  ------ Seta valor Unidade de Milhar


tmp(219) := STA & '1' & x"FE";	-- #STA @510                     	--  Limpa KEY1

tmp(220) := LDI & '0' & x"08";	-- #LDI $8
tmp(221) := STA & '1' & x"00";	-- #STA @256                     	--  LEDR4 -> Indicativo limite Centena

tmp(222) := LDA & '1' & x"40";	-- #LDA @320                     	--  Lê chaves
tmp(223) := STA & '0' & x"17";	-- #STA @23                      	--  Salva valor limite unidade de milhar em MEN[23]
tmp(224) := STA & '1' & x"23";	-- #STA @291                     	--  HEX3 = Valor da dezena setado

tmp(225) := LDA & '1' & x"61";	-- #LDA @353                     	--  Observa KEY1 ->  (1 -> Seta Dezena Milhar  ; 0 -> Seta Unidade de Milhar) 
tmp(226) := OP_AND & '0' & x"01";	-- #OP_AND @1 
tmp(227) := CEQ & '0' & x"01";	-- #CEQ @1 
tmp(228) := JEQ & '0' & x"E8";	-- #JEQ @232	-- JEQ .SET_DEZENA_MILHAR
tmp(229) := NOP & '0' & x"00";	-- #NOP
tmp(230) := JMP & '0' & x"DB";	-- #JMP @219	-- JMP .SET_UNIDADE_MILHAR
tmp(231) := NOP & '0' & x"00";	-- #NOP

--  ------ Seta valor Dezena de Milhar


tmp(232) := STA & '1' & x"FE";	-- #STA @510                     	--  Limpa KEY1

tmp(233) := LDI & '0' & x"10";	-- #LDI $16
tmp(234) := STA & '1' & x"00";	-- #STA @256                     	--  LEDR5 -> Indicativo limite Centena

tmp(235) := LDA & '1' & x"40";	-- #LDA @320                     	--  Lê chaves
tmp(236) := STA & '0' & x"18";	-- #STA @24                      	--  Salva valor limite unidade de milhar em MEN[24]
tmp(237) := STA & '1' & x"24";	-- #STA @292                     	--  HEX4 = Valor da dezena setado

tmp(238) := LDA & '1' & x"61";	-- #LDA @353                     	--  Observa KEY1 ->  (1 -> Seta  Centena de Milhar  ; 0 -> Seta Dezena de Milhar) 
tmp(239) := OP_AND & '0' & x"01";	-- #OP_AND @1 
tmp(240) := CEQ & '0' & x"01";	-- #CEQ @1 
tmp(241) := JEQ & '0' & x"F5";	-- #JEQ @245	-- JEQ .SET_CENTENA_MILHAR
tmp(242) := NOP & '0' & x"00";	-- #NOP
tmp(243) := JMP & '0' & x"E8";	-- #JMP @232	-- JMP .SET_DEZENA_MILHAR
tmp(244) := NOP & '0' & x"00";	-- #NOP


--  ------ Seta valor Dezena de Milhar


tmp(245) := STA & '1' & x"FE";	-- #STA @510                     	--  Limpa KEY1

tmp(246) := LDI & '0' & x"20";	-- #LDI $32
tmp(247) := STA & '1' & x"00";	-- #STA @256                     	--  LEDR5 -> Indicativo limite Centena

tmp(248) := LDA & '1' & x"40";	-- #LDA @320                     	--  Lê chaves
tmp(249) := STA & '0' & x"19";	-- #STA @25                      	--  Salva valor limite unidade de milhar em MEN[25]
tmp(250) := STA & '1' & x"25";	-- #STA @293                     	--  HEX4 = Valor da dezena setado

tmp(251) := LDA & '1' & x"42";	-- #LDA @322                     	--  Observa SW9 ->  (1 -> Seta  Centena de Milhar  ; 0 -> Seta Dezena de Milhar) 
tmp(252) := OP_AND & '0' & x"01";	-- #OP_AND @1 
tmp(253) := CEQ & '0' & x"00";	-- #CEQ @0 
tmp(254) := JEQ & '1' & x"02";	-- #JEQ @258	-- JEQ .FIM_LIMITE_CONTADOR
tmp(255) := NOP & '0' & x"00";	-- #NOP
tmp(256) := JMP & '0' & x"F5";	-- #JMP @245	-- JMP .SET_CENTENA_MILHAR
tmp(257) := NOP & '0' & x"00";	-- #NOP

--  ------ Desativa modo Limite Contador

tmp(258) := LDI & '0' & x"00";	-- #LDI $0                        	--  LEDR9 = 0
tmp(259) := STA & '1' & x"02";	-- #STA @258
tmp(260) := STA & '1' & x"00";	-- #STA @256                      	--  LEDR0-7 = 0

--  Limpa Displays
tmp(261) := LDI & '0' & x"00";	-- #LDI $0
tmp(262) := STA & '1' & x"20";	-- #STA @288
tmp(263) := STA & '1' & x"21";	-- #STA @289
tmp(264) := STA & '1' & x"22";	-- #STA @290
tmp(265) := STA & '1' & x"23";	-- #STA @291
tmp(266) := STA & '1' & x"24";	-- #STA @292
tmp(267) := STA & '1' & x"25";	-- #STA @293

tmp(268) := JMP & '1' & x"11";	-- #JMP @273	-- JMP .MAIN
tmp(269) := NOP & '0' & x"00";	-- #NOP

--  -------------- REINICIA CONTAGEM -----------------


tmp(270) := STA & '1' & x"FD";	-- #STA @509
tmp(271) := JMP & '0' & x"00";	-- #JMP @0	-- JMP .SETUP
tmp(272) := NOP & '0' & x"00";	-- #NOP

--  -------------- ROTINA PRINCIPAL -----------------


tmp(273) := LDA & '1' & x"60";	-- #LDA @352                      	--  Lê KEY0 
tmp(274) := OP_AND & '0' & x"01";	-- #OP_AND @1
tmp(275) := CEQ & '0' & x"01";	-- #CEQ @1                        
tmp(276) := JEQ & '0' & x"21";	-- #JEQ @33	--  APERTADO
tmp(277) := NOP & '0' & x"00";	-- #NOP
tmp(278) := LDA & '1' & x"42";	-- #LDA @322                      	--  Lê chave SW9 -> Limite de Incremento
tmp(279) := OP_AND & '0' & x"01";	-- #OP_AND @1 
tmp(280) := CEQ & '0' & x"01";	-- #CEQ @1                          
tmp(281) := JEQ & '0' & x"B2";	-- #JEQ @178	--  Modo de inserir limite selecionado
tmp(282) := NOP & '0' & x"00";	-- #NOP
tmp(283) := LDA & '1' & x"64";	-- #LDA @356                      	--  FPGA_RESET : Limpa Contador e reinicia contagem
tmp(284) := OP_AND & '0' & x"01";	-- #OP_AND @1
tmp(285) := CEQ & '0' & x"01";	-- #CEQ @1 
tmp(286) := JEQ & '1' & x"0E";	-- #JEQ @270	-- JEQ .REINICIA_CONTAGEM        
tmp(287) := NOP & '0' & x"00";	-- #NOP
tmp(288) := JMP & '1' & x"11";	-- #JMP @273	-- JMP .MAIN
tmp(289) := NOP & '0' & x"00";	-- #NOP

						
        return tmp;
    end initMemory;

    signal memROM : blocoMemoria := initMemory;

begin
    Dado <= memROM (to_integer(unsigned(Endereco)));
end architecture;