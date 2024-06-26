library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_hdr is
  port
  (

    ---- FPGA I/O ----
    CLOCK_50 : in std_logic;
    KEY      : in std_logic_vector(3 downto 0);
    SW       : in std_logic_vector(15 downto 0);

    -- vers VGA
    VGA_CLK     : out std_logic; --Clock
    VGA_HS      : inout std_logic; --H_SYNC
    VGA_VS      : inout std_logic; --V_SYNC
    VGA_BLANK_N : out std_logic; --BLANK
    VGA_SYNC_N  : out std_logic; --SYNC
    VGA_R       : out std_logic_vector(7 downto 0); --Red  [7:0]
    VGA_G       : out std_logic_vector(7 downto 0); --Green[7:0]
    VGA_B       : out std_logic_vector(7 downto 0); --Blue [7:0]

    -- depuis CMOS
    CMOS_DATA   : in std_logic_vector(9 downto 0);
    CMOS_PIXCLK : in std_logic;
    CMOS_LVAL   : in std_logic;
    CMOS_FVAL   : in std_logic;

    -- vers CMOS
    CMOS_MCLK : out std_logic;
    CMOS_SCLK : out std_logic;
    CMOS_SDAT : inout std_logic;

    LEDG : out std_logic_vector(7 downto 0);
    --GPIO        : out std_logic_vector(31 downto 0) -- vers logicport

    --GPIO_J2     : inout std_logic_vector(35 downto 4) -- depuis camera CMOS
    --GPIO_J3     : inout std_logic_vector(35 downto 4)  -- vers logicport

    -- DRAM SIGNALS
    DRAM_ADDR   : out std_logic_vector(12 downto 0);
    DRAM_DQ     : inout std_logic_vector(15 downto 0);
    DRAM_WE_N   : out std_logic;
    DRAM_CAS_N  : out std_logic;
    DRAM_RAS_N  : out std_logic;
    DRAM_CS_N   : out std_logic;
    DRAM_CLK    : out std_logic;
    DRAM_UDQM   : out std_logic_vector(1 downto 0);
    DRAM_LDQM   : out std_logic_vector(1 downto 0);
    DRAM_BA     : out std_logic_vector(1 downto 0)

  );
end top_hdr;

architecture rtl of top_hdr is






component hdr_control_unit is port (
  clock					:	in		std_logic;
  reset					:	in		std_logic;
  LUT_NORMAL_OFFSET				:	out		integer; -- Offset de la LUT inverse
  LUT_INVERSE_OFFSET				:	out		integer; -- Offset de la LUT normale
  choice_lut_vector				:	in		std_logic_vector(3 downto 0) -- Vecteur de choix de la LUT
); 
end component;




component hdr_datapath is port (
          clock						:	in		std_logic;
        clock_25					:	in		std_logic;
        reset						:	in		std_logic;
        exposition				:	in		std_logic_vector(11 downto 0);

    -- Paramètres de la CAMERA
        camera_serial_clock	:	out	std_logic;
        camera_master_clock	:	out	std_logic;
        camera_serial_data	: 	inout	std_logic;
        camera_line_valid		:	in		std_logic;
        camera_frame_valid	:	in		std_logic;
        camera_pixel_clock	:	in		std_logic;
        camera_data				:	in		std_logic_vector(9 downto 0);

-- Paramètres de la VGA
        vga_hsync				:	inout	std_logic;
        vga_vsync				:	inout	std_logic;
        vga_red					:	out	std_logic_vector(7 downto 0);
        vga_green				:	out	std_logic_vector(7 downto 0);
        vga_blue					:	out	std_logic_vector(7 downto 0);
        vga_nblank				:	out	std_logic;
        vga_nsync				:	out	std_logic;
        vga_clock				:	out	std_logic;
        
        -- paramètres de la LUT
        lut_normal_offset			:	in		integer;
        lut_inverse_offset            :	in		integer

);
  
  end component;






signal exposition_internal	:	std_logic_vector(11 downto 0);
signal choice_lut_vector_internal : std_logic_vector(3 downto 0);
signal lut_normal_offset_internal		:	integer;
signal lut_inverse_offset_internal		:	integer;

signal clock_25	:	std_logic := '0';



begin 

choice_lut_vector_internal <= SW(3 downto 0);
exposition_internal	<= SW(15 downto 4);



p0: process(CLOCK_50)
	begin
		if rising_edge(CLOCK_50) then
			clock_25 <= not clock_25;
		end if;
	end process;




G0: hdr_control_unit port map(
		clock					=> CLOCK_50,
		reset					=> not KEY(0),
		LUT_NORMAL_OFFSET => lut_normal_offset_internal,
		LUT_INVERSE_OFFSET=> lut_inverse_offset_internal,
		choice_lut_vector	=> choice_lut_vector_internal);
	


	G1: hdr_datapath port 
  map(
		clock						=> CLOCK_50,
		clock_25					=>	clock_25,
		reset						=> not KEY(0),

		exposition				=> exposition_internal,
		camera_serial_clock	=> CMOS_SCLK,
		camera_master_clock	=> CMOS_MCLK,
		camera_serial_data	=> CMOS_SDAT,
		camera_line_valid		=> CMOS_LVAL,
		camera_frame_valid	=> CMOS_FVAL,
		camera_data				=> CMOS_DATA,
		camera_pixel_clock	=> CMOS_PIXCLK,


		vga_hsync				=> VGA_HS,
		vga_vsync				=> VGA_VS,
		vga_red					=> VGA_R,
		vga_green				=> VGA_G,
		vga_blue					=> VGA_B,
		vga_nblank				=> VGA_BLANK_N,
		vga_nsync				=> VGA_SYNC_N,
		vga_clock				=> VGA_CLK,
    -- paramètres de la LUT
    lut_normal_offset => lut_normal_offset_internal,
    lut_inverse_offset => lut_inverse_offset_internal
    );



    



end rtl;