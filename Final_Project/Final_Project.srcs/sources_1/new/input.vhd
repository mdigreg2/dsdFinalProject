-- Trevor Dawideit
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY input IS
	PORT (
		clk_50MHz : IN STD_LOGIC; -- system clock (50 MHz)
		SEG7_anode : OUT STD_LOGIC_VECTOR (3 DOWNTO 0); -- anodes of four 7-seg displays
		SEG7_seg : OUT STD_LOGIC_VECTOR (6 DOWNTO 0); -- common segments of 7-seg displays
		col : in STD_LOGIC_VECTOR (4 DOWNTO 1)); -- indicates when a key has been pressed
END input;

ARCHITECTURE Behavioral OF input IS
COMPONENT leddec16 IS
		PORT (
			dig : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
			data : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
			anode : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
			seg : OUT STD_LOGIC_VECTOR (6 DOWNTO 0)
		);
	END COMPONENT;
	SIGNAL cnt : std_logic_vector(20 DOWNTO 0);
	SIGNAL led_mpx : STD_LOGIC_VECTOR (1 DOWNTO 0);
	SIGNAL display : std_logic_vector (15 DOWNTO 0);
	SIGNAL kp_clk, kp_hit, sm_clk : std_logic;
	TYPE state IS (ENTER_ACC, ACC_RELEASE, START_OP, OP_RELEASE, 
	ENTER_OP, SHOW_RESULT);
	SIGNAL pr_state, nx_state : state;
BEGIN
	ck_proc : PROCESS (clk_50MHz)
	BEGIN 
	   IF rising_edge(clk_50MHz) THEN -- on rising edge of clock
	       cnt <= cnt + 1; -- increment counter
	   END IF;
	END PROCESS;
	kp_clk <= cnt(15); -- keypad interrogation clock
	sm_clk <= cnt(20); -- state machine clock
	led1 : leddec16
	   PORT MAP(
		  dig => led_mpx, data => display,
		  anode => SEG7_anode, seg => SEG7_seg
	   );
	led_mpx <= cnt(18 DOWNTO 17);
    sm_ck_pr : PROCESS (sm_clk) -- state machine clock process
	BEGIN
		IF rising_edge (sm_clk) THEN -- on rising clock edge
			pr_state <= nx_state; -- update present state
		END IF;
	END PROCESS;
    col_sel: process
    BEGIN
    WAIT UNTIL rising_edge(clk_50MHz);
	IF col = 0001 THEN
	   display <= "0000000000000001";
	ELSIF col = 0010 THEN
	   display <= "0000000000000010";
	ELSIF col = 0100 THEN
	   display <= "0000000000000011";
	ELSIF col = 1000 THEN
	   display <= "0000000000000100";
--	ELSE
--	   display <= "0000000000000000";
    ELSIF col = 0011 THEN
	   display <= "0000000000100001";
	ELSIF col = 0101 THEN
	   display <= "0000000000000101";
	ELSIF col = 0110 THEN
	   display <= "0000000000000110";
	ELSIF col = 0111 THEN
	   display <= "0000000000000111";
    ELSIF col = 1001 THEN
	   display <= "0000000000001001";
	ELSIF col = 1010 THEN
	   display <= "0000000000001010";
	ELSIF col = 1011 THEN
	   display <= "0000000000001011";
	ELSIF col = 1100 THEN
	   display <= "0000000000001100";
	ELSIF col = 1101 THEN
	   display <= "0000000000001101";
	ELSIF col = 1110 THEN
	   display <= "0000000000001110";
	ELSIF col = 1111 THEN
	   display <= "0000000000001111";
	END IF;
    end process;
END Behavioral;