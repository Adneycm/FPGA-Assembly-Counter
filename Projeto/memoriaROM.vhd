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
tmp(22) := STA & '0' & x"0E";	-- #STA @14       	--  MEN[14] = Centena de Milhar
tmp(23) := STA & '0' & x"0F";	-- #STA @15       	--  MEN[15] = Unidade de Milhão

tmp(24) := JMP & '0' & x"3D";	-- #JMP @61	--  Pula para Rotina Principal
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
tmp(34) := STA & '0' & x"0A";	-- #STA @10        	--  MEN[10] = Unidade_incrementada
tmp(35) := STA & '1' & x"20";	-- #STA @288       	--  HEX0 = Unidade
tmp(36) := JMP & '0' & x"3B";	-- #JMP @59	-- JMP .FIM_INCREMENTO
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
tmp(46) := STA & '0' & x"0B";	-- #STA @11        	--  MEN[11] = Dezena_incrementada
tmp(47) := STA & '1' & x"21";	-- #STA @289       	--  HEX1 = Dezena
tmp(48) := JMP & '0' & x"3B";	-- #JMP @59	-- JMP .FIM_INCREMENTO
tmp(49) := NOP & '0' & x"00";	-- #NOP

--  ------- Incrementa  Centena

--  Zera dezena
tmp(50) := LDI & '0' & x"00";	-- #LDI $0
tmp(51) := STA & '0' & x"0B";	-- #STA @11
tmp(52) := STA & '1' & x"21";	-- #STA @289

tmp(53) := LDA & '0' & x"0C";	-- #LDA @12        	--  Carrega centena
tmp(54) := SOMA & '0' & x"01";	-- #SOMA @1
tmp(55) := STA & '0' & x"0C";	-- #STA @12        	--  MEN[12] = Centena_incrementada
tmp(56) := STA & '1' & x"22";	-- #STA @290       	--  HEX2 = Centena
tmp(57) := JMP & '0' & x"3B";	-- #JMP @59	-- JMP .FIM_INCREMENTO
tmp(58) := NOP & '0' & x"00";	-- #NOP

--  ------- FIM INCREMENTO

tmp(59) := JMP & '0' & x"3D";	-- #JMP @61	-- JMP .VERIFICA_KEY0
tmp(60) := NOP & '0' & x"00";	-- #NOP

--  -------------- ROTINA PRINCIPAL -----------------



--  Verifica estado do KEY0
tmp(61) := LDA & '1' & x"60";	-- #LDA @352                      	--  Lê KEY0 
tmp(62) := CEQ & '0' & x"00";	-- #CEQ @0                        	--  Verifica se foi apertado (KEY0 = 0 ?)
tmp(63) := JEQ & '0' & x"3D";	-- #JEQ @61	--  NAO APERTADO
tmp(64) := NOP & '0' & x"00";	-- #NOP
tmp(65) := JSR & '0' & x"1A";	-- #JSR @26	--  APERTADO
tmp(66) := NOP & '0' & x"00";	-- #NOP
tmp(67) := NOP & '0' & x"00";	-- #NOP

				
        return tmp;
    end initMemory;

    signal memROM : blocoMemoria := initMemory;

begin
    Dado <= memROM (to_integer(unsigned(Endereco)));
end architecture;