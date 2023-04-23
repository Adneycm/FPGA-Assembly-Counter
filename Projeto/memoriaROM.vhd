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

tmp(24) := JMP & '0' & x"73";	-- #JMP @115	--  Pula para Rotina Principal
tmp(25) := NOP & '0' & x"00";	-- #NOP

--  -------------- INCREMENTA CONTADOR ---------------


tmp(26) := STA & '1' & x"FF";	-- #STA @511       	--  Endereco 511 : Limpa Flag FlipFlop KEY0
tmp(27) := LDA & '0' & x"0A";	-- #LDA @10        	--  REGA = Unidade

--  Verifica se valor da unidade é igual a 9:
tmp(28) := CEQ & '0' & x"09";	-- #CEQ @9         	--  Unidade já é = 9?
tmp(29) := JEQ & '0' & x"26";	-- #JEQ @38	--  SIM : Incrementa dezena
tmp(30) := NOP & '0' & x"00";	-- #NOP
tmp(31) := JEQ & '0' & x"21";	-- #JEQ @33	--  NÃO : Incrementa unidade
tmp(32) := NOP & '0' & x"00";	-- #NOP 

--  ------- Incrementa  Unidade

tmp(33) := SOMA & '0' & x"01";	-- #SOMA @1        	--  REGA = Unidade + 1
tmp(34) := STA & '0' & x"0A";	-- #STA @10        
tmp(35) := STA & '1' & x"20";	-- #STA @288       	--  HEX0 = Unidade
tmp(36) := JMP & '0' & x"65";	-- #JMP @101	-- JMP .FIM_INCREMENTO
tmp(37) := NOP & '0' & x"00";	-- #NOP

--  ------- Incrementa  Dezena

--  Zera unidade
tmp(38) := LDI & '0' & x"00";	-- #LDI $0
tmp(39) := STA & '0' & x"0A";	-- #STA @10
tmp(40) := STA & '1' & x"20";	-- #STA @288       	--  HEX0 = Unidade

tmp(41) := LDA & '0' & x"0B";	-- #LDA @11        	--  Dezena já é 9 ? 
tmp(42) := CEQ & '0' & x"09";	-- #CEQ @9         
tmp(43) := JEQ & '0' & x"32";	-- #JEQ @50	--  Sim

tmp(44) := LDA & '0' & x"0B";	-- #LDA @11        	--  Carrega dezena
tmp(45) := SOMA & '0' & x"01";	-- #SOMA @1
tmp(46) := STA & '0' & x"0B";	-- #STA @11        
tmp(47) := STA & '1' & x"21";	-- #STA @289       	--  HEX1 = Dezena
tmp(48) := JMP & '0' & x"65";	-- #JMP @101	-- JMP .FIM_INCREMENTO
tmp(49) := NOP & '0' & x"00";	-- #NOP

--  ------- Incrementa  Centena

--  Zera dezena
tmp(50) := LDI & '0' & x"00";	-- #LDI $0
tmp(51) := STA & '0' & x"0B";	-- #STA @11
tmp(52) := STA & '1' & x"21";	-- #STA @289

tmp(53) := LDA & '0' & x"0C";	-- #LDA @12        	--  Centena já é 9?
tmp(54) := CEQ & '0' & x"09";	-- #CEQ @9
tmp(55) := JEQ & '0' & x"3E";	-- #JEQ @62	-- JEQ .UNIDADE_MILHAR

tmp(56) := LDA & '0' & x"0C";	-- #LDA @12        	--  Carrega centena
tmp(57) := SOMA & '0' & x"01";	-- #SOMA @1
tmp(58) := STA & '0' & x"0C";	-- #STA @12        
tmp(59) := STA & '1' & x"22";	-- #STA @290       	--  HEX2 = Centena
tmp(60) := JMP & '0' & x"65";	-- #JMP @101	-- JMP .FIM_INCREMENTO
tmp(61) := NOP & '0' & x"00";	-- #NOP

--  ------- Incrementa Unidade de Milhar

--  Zera centena
tmp(62) := LDI & '0' & x"00";	-- #LDI $0
tmp(63) := STA & '0' & x"0C";	-- #STA @12
tmp(64) := STA & '1' & x"22";	-- #STA @290

tmp(65) := LDA & '0' & x"0D";	-- #LDA @13        	--  Unidade de milhar já é 9?
tmp(66) := CEQ & '0' & x"09";	-- #CEQ @9
tmp(67) := JEQ & '0' & x"4A";	-- #JEQ @74	-- JEQ .DEZENA_MILHAR

tmp(68) := LDA & '0' & x"0D";	-- #LDA @13       	--  Carrega unidade de milhar
tmp(69) := SOMA & '0' & x"01";	-- #SOMA @1
tmp(70) := STA & '0' & x"0D";	-- #STA @13
tmp(71) := STA & '1' & x"23";	-- #STA @291      	--  HEX3 = Unidade de milhar

tmp(72) := JMP & '0' & x"65";	-- #JMP @101	-- JMP .FIM_INCREMENTO
tmp(73) := NOP & '0' & x"00";	-- #NOP

--  ------- Incrementa Dezena de Milhar

--  Zera unidade de milhar
tmp(74) := LDI & '0' & x"00";	-- #LDI $0
tmp(75) := STA & '0' & x"0D";	-- #STA @13
tmp(76) := STA & '1' & x"23";	-- #STA @291

tmp(77) := LDA & '0' & x"0E";	-- #LDA @14      	--  Dezena de Milhar já é 9?
tmp(78) := CEQ & '0' & x"09";	-- #CEQ @9
tmp(79) := JEQ & '0' & x"56";	-- #JEQ @86	-- JEQ .CENTENA_MILHAR

tmp(80) := LDA & '0' & x"0E";	-- #LDA @14       	--  Carrega dezena de milhar
tmp(81) := SOMA & '0' & x"01";	-- #SOMA @1
tmp(82) := STA & '0' & x"0E";	-- #STA @14
tmp(83) := STA & '1' & x"24";	-- #STA @292      	--  HEX4 = Unidade de milhar

tmp(84) := JMP & '0' & x"65";	-- #JMP @101	-- JMP .FIM_INCREMENTO
tmp(85) := NOP & '0' & x"00";	-- #NOP

--  ------- Incrementa Centena de Milhar

--  Zera dezena de milhar
tmp(86) := LDI & '0' & x"00";	-- #LDI $0
tmp(87) := STA & '0' & x"0E";	-- #STA @14
tmp(88) := STA & '1' & x"24";	-- #STA @292

tmp(89) := LDA & '0' & x"0F";	-- #LDA @15      	--  Centena de Milhar já é 9?
tmp(90) := CEQ & '0' & x"09";	-- #CEQ @9
tmp(91) := JEQ & '0' & x"62";	-- #JEQ @98	-- JEQ .ZERA_CENTENA_MILHAR

tmp(92) := LDA & '0' & x"0F";	-- #LDA @15       	--  Carrega dezena de milhar
tmp(93) := SOMA & '0' & x"01";	-- #SOMA @1
tmp(94) := STA & '0' & x"0F";	-- #STA @15
tmp(95) := STA & '1' & x"25";	-- #STA @293      	--  HEX5 = Centena de milhar

tmp(96) := JMP & '0' & x"65";	-- #JMP @101	-- JMP .FIM_INCREMENTO
tmp(97) := NOP & '0' & x"00";	-- #NOP

-- Zera centena de milhar

tmp(98) := LDI & '0' & x"00";	-- #LDI $0
tmp(99) := STA & '0' & x"0F";	-- #STA @15
tmp(100) := STA & '1' & x"25";	-- #STA @293

--  ------- FIM INCREMENTO

tmp(101) := JMP & '0' & x"73";	-- #JMP @115	-- JMP .MAIN
tmp(102) := NOP & '0' & x"00";	-- #NOP

--  --------------- LIMITE CONTADOR ----------------


tmp(103) := LDI & '0' & x"01";	-- #LDI $1
tmp(104) := STA & '1' & x"02";	-- #STA @258                      	--  Indicativo de que esse modo foi selecionado. LEDR9

tmp(105) := LDA & '1' & x"42";	-- #LDA @322                      
tmp(106) := CEQ & '0' & x"00";	-- #CEQ @0
tmp(107) := JEQ & '0' & x"6F";	-- #JEQ @111	--  Deseleciona Modo : FIM_LIMITE_CONTADOR
tmp(108) := NOP & '0' & x"00";	-- #NOP

--  Subrotina configura unidade

tmp(109) := JMP & '0' & x"67";	-- #JMP @103	-- JMP .LIMITE_CONTADOR
tmp(110) := NOP & '0' & x"00";	-- #NOP

--  Desativa modo Limite Contador

tmp(111) := LDI & '0' & x"00";	-- #LDI $0                        	--  LEDR9 = 0
tmp(112) := STA & '1' & x"02";	-- #STA @258 
tmp(113) := JMP & '0' & x"73";	-- #JMP @115	-- JMP .MAIN
tmp(114) := NOP & '0' & x"00";	-- #NOP

--  -------------- ROTINA PRINCIPAL -----------------


--  Verifica estado do KEY0
tmp(115) := LDA & '1' & x"60";	-- #LDA @352                      	--  Lê KEY0 
tmp(116) := CEQ & '0' & x"01";	-- #CEQ @1                        
tmp(117) := JEQ & '0' & x"1A";	-- #JEQ @26	--  APERTADO
tmp(118) := NOP & '0' & x"00";	-- #NOP
tmp(119) := LDA & '1' & x"42";	-- #LDA @322                      	--  Lê chave SW9 -> Limite de Incremento
tmp(120) := CEQ & '0' & x"01";	-- #CEQ @1                           
tmp(121) := JEQ & '0' & x"67";	-- #JEQ @103	--  Modo de inserir limite selecionado
tmp(122) := NOP & '0' & x"00";	-- #NOP
tmp(123) := JMP & '0' & x"73";	-- #JEQ @115	-- JEQ .MAIN
tmp(124) := NOP & '0' & x"00";	-- #NOP


        return tmp;
    end initMemory;

    signal memROM : blocoMemoria := initMemory;

begin
    Dado <= memROM (to_integer(unsigned(Endereco)));
end architecture;