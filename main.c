#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <qdos.h>
#include <dirent.h>
#include <stdio.h>

#define uint32_t unsigned short
#define int32_t short
#define uint8_t unsigned char

#ifndef DEVICE_LOADFROM
#error "Define DEVICE_LOADFROM to something like flp1 or mdv1"
#endif

char main_device_name[6] = DEVICE_LOADFROM"_";
unsigned char i;

#define SCREEN_MODE_ADDR ((volatile unsigned char*)0x18063)

#define SET_HIGH_RESOLUTION() *SCREEN_MODE_ADDR = (0 << 3);
#define SET_LOW_RESOLUTION() *SCREEN_MODE_ADDR = (1 << 3);

#define SCR8_START_ADDRESS ((volatile void*)0x20000)

#ifdef _512KB
// Use 0x40000 for Expanded RAM
#define TEMP_RAM_AREA ((volatile void*)0x40000)
#else
// Assume default 128KB configuration

// This is the higher memory area that's free for us
// If we attempt to go further, we overwrite our own memory
//#define TEMP_RAM_AREA ((volatile void*)0x3A000)

// Stock ROM can go further at 0x2A000
// but Minerva, this is as far as we can go...
#define TEMP_RAM_AREA ((volatile void*)0x2C000)

#endif

WINDOWDEF_t my_windef = { 
		WHITE_M4, 0, 
		BLACK_M4, 
		RED_M4, 
		512, 40, 
		0, 256-40
};
WINDOWDEF_t empty = { 
		WHITE_M4, 0, 
		BLACK_M4, 
		RED_M4, 
		0, 0, 
		0, 0
};
chanid_t in;

#define Init_text() in =  ut_con ( &my_windef );
#define Disable_text() in =  ut_con ( &empty );

void Print_text(const char* str, unsigned char text_size)
{
	char buffer[96];
	QLSTR_t* p_qlstr;
	sd_setsz( in, 1, 1, 0 );
	sd_setin( in, 1, WHITE_M4 );
	p_qlstr = (QLSTR_t*)buffer;
	sprintf( p_qlstr->qs_str, str);
	p_qlstr->qs_strlen = text_size;
	ut_mtext( in, p_qlstr );
}

unsigned char open_image_to_buffer(const char* fname, void* buf, unsigned short fsize)
{
    chanid_t fil;
    char temp[16];
    sprintf(temp, "%s%s", main_device_name, fname);
    
    fil = io_open(temp, 0x01);
    if (fil < 0) return 0;
	fs_load(fil, buf, fsize);
	io_close(fil);

	return 0;
}


const unsigned char ZX0_compressed_buffer[54] = {
    0x53, 0x4f, 0x68, 0x20, 0x6d, 0x79, 0x2c, 0x20,
    0x77, 0x68, 0x61, 0x74, 0x20, 0x64, 0x6f, 0x8e,
    0xf1, 0x65, 0x20, 0xed, 0xe8, 0x76, 0xf6, 0x88,
    0x65, 0x72, 0x1a, 0x3f, 0x5c, 0x6e, 0x59, 0x6f,
    0x75, 0x20, 0x6c, 0x6f, 0xaa, 0x6b, 0x73, 0x0a,
    0x20, 0x69, 0x6e, 0x6e, 0x28, 0x63, 0x65, 0xed,
    0x74, 0x2e, 0xff, 0x0a, 0x55, 0x56
};

//#define NV2S 1
//#define APLIB 1
//#define SLZ 1
//#define LZ4W 1

extern void zx0_decompress(void *src, const void *dst);
extern unsigned int apl_unpack(void *source, void *destination);
extern unsigned int nrv2s_unpack(void *source, void *destination);
extern unsigned int lz4w_unpack(void * source, void *destination);
extern void DecompressSlz(void *src, const void *dst);

int main()
{
    FILE* fp;
    long file_size;
    int i;
    short mode = 8;
	// Turn on Supervisor mode
	// This is much faster than the default
	// Thanks SMFX for the advice
	asm ("trap    #0");
	asm ("or.w    #$700,sr");

    mt_dmode(&mode, -1);
   
#ifdef NV2S
	#warning "NV2S"
	open_image_to_buffer("IMGNV", (void*)TEMP_RAM_AREA, 13582);
	nrv2s_unpack((void*)TEMP_RAM_AREA, (void*)SCR8_START_ADDRESS);
#elif defined(APLIB)
	#warning "APLIB"
	open_image_to_buffer("IMGAP", (void*)TEMP_RAM_AREA, 13537);
	apl_unpack((void*)TEMP_RAM_AREA, (void*)SCR8_START_ADDRESS);
#elif defined(SLZ)
	#warning "SLZ"
	open_image_to_buffer("IMGSLZ", (void*)TEMP_RAM_AREA, 15183);
	DecompressSlz((void*)TEMP_RAM_AREA, (void*)SCR8_START_ADDRESS);
#elif defined(LZ4W)
	#warning "LZ4W"
	open_image_to_buffer("IMGLZ4W", (void*)TEMP_RAM_AREA, 19640);
	lz4w_unpack((void*)TEMP_RAM_AREA, (void*)SCR8_START_ADDRESS);
#else 
	#warning "ZX0"
	open_image_to_buffer("IMGZX0", (void*)TEMP_RAM_AREA, 13710);
	zx0_decompress((void*)TEMP_RAM_AREA, (void*)SCR8_START_ADDRESS);
#endif



    //Init_text();
	//Print_text("YES  ", 5);

	
	while(1)
	{
		
	}
	
	return 0;
}
