-- Trevor Dawideit and Christopher Waldt
library IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY siren IS
	PORT (
		clk_50MHz : IN STD_LOGIC; -- system clock (50 MHz)
		dac_MCLK : OUT STD_LOGIC; -- outputs to PMODI2L DAC
		dac_LRCK : OUT STD_LOGIC;
		dac_SCLK : OUT STD_LOGIC;
		dac_SDIN : OUT STD_LOGIC;
		SEG7_anode : OUT STD_LOGIC_VECTOR (3 DOWNTO 0); -- anodes of four 7-seg displays
		SEG7_seg : OUT STD_LOGIC_VECTOR (6 DOWNTO 0); -- common segments of 7-seg displays
	    col : in STD_LOGIC_VECTOR (4 DOWNTO 1) -- indicates when a key has been pressed
	);
END siren;

ARCHITECTURE Behavioral OF siren IS
	CONSTANT lo_tone : UNSIGNED (13 DOWNTO 0) := to_unsigned (344, 14); -- lower limit of siren = 256 Hz
	CONSTANT hi_tone : UNSIGNED (13 DOWNTO 0) := to_unsigned (687, 14); -- upper limit of siren = 512 Hz
	CONSTANT wail_speed : UNSIGNED (7 DOWNTO 0) := to_unsigned (8, 8); -- sets wailing speed
	COMPONENT leddec16 IS
		PORT (
			dig : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
			data : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
			anode : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
			seg : OUT STD_LOGIC_VECTOR (6 DOWNTO 0)
		);
	END COMPONENT;
	COMPONENT dac_if IS
		PORT (
			SCLK : IN STD_LOGIC;
			L_start : IN STD_LOGIC;
			R_start : IN STD_LOGIC;
			L_data : IN signed (15 DOWNTO 0);
			R_data : IN signed (15 DOWNTO 0);
			SDATA : OUT STD_LOGIC
		);
	END COMPONENT;
	COMPONENT wail IS
		PORT (
			lo_pitch : IN UNSIGNED (13 DOWNTO 0);
			hi_pitch : IN UNSIGNED (13 DOWNTO 0);
			wspeed : IN UNSIGNED (7 DOWNTO 0);
			wclk : IN STD_LOGIC;
			audio_clk : IN STD_LOGIC;
			audio_data : OUT SIGNED (15 DOWNTO 0);
			input : IN STD_LOGIC_VECTOR (4 DOWNTO 1)
		);
	END COMPONENT;
	SIGNAL tcount : unsigned (19 DOWNTO 0) := (OTHERS => '0'); -- timing counter
	SIGNAL data_L, data_R : SIGNED (15 DOWNTO 0); -- 16-bit signed audio data
	SIGNAL dac_load_L, dac_load_R : STD_LOGIC; -- timing pulses to load DAC shift reg.
	SIGNAL slo_clk, sclk, audio_CLK : STD_LOGIC;
	SIGNAL input: STD_LOGIC_VECTOR(4 DOWNTO 1);
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
	-- this process sets up a 20 bit binary counter clocked at 50MHz. This is used
	-- to generate all necessary timing signals. dac_load_L and dac_load_R are pulses
	-- sent to dac_if to load parallel data into shift register for serial clocking
	-- out to DAC
	tim_pr : PROCESS
	BEGIN
		WAIT UNTIL rising_edge(clk_50MHz);
		IF (tcount(9 DOWNTO 0) >= X"00F") AND (tcount(9 DOWNTO 0) < X"02E") THEN
			dac_load_L <= '1';
		ELSE
			dac_load_L <= '0';
		END IF;
		IF (tcount(9 DOWNTO 0) >= X"20F") AND (tcount(9 DOWNTO 0) < X"22E") THEN
			dac_load_R <= '1';
		ELSE dac_load_R <= '0';
		END IF;
		tcount <= tcount + 1;
	END PROCESS;
	dac_MCLK <= NOT tcount(1); -- DAC master clock (12.5 MHz)
	audio_CLK <= tcount(9); -- audio sampling rate (48.8 kHz)
	dac_LRCK <= audio_CLK; -- also sent to DAC as left/right clock
	sclk <= tcount(4); -- serial data clock (1.56 MHz)
	dac_SCLK <= sclk; -- also sent to DAC as SCLK
	slo_clk <= tcount(19); -- clock to control wailing of tone (47.6 Hz)
	dac : dac_if
	PORT MAP(
		SCLK => sclk, -- instantiate parallel to serial DAC interface
		L_start => dac_load_L, 
		R_start => dac_load_R, 
		L_data => data_L, 
		R_data => data_R, 
		SDATA => dac_SDIN 
		);
		w1 : wail
		PORT MAP(
			lo_pitch => lo_tone, -- instantiate wailing siren
			hi_pitch => hi_tone, 
			wspeed => wail_speed, 
			wclk => slo_clk, 
			audio_clk => audio_clk, 
			audio_data => data_L,
			input => col
		);
		data_R <= data_L; -- duplicate data on right channel
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
