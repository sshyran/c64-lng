/* package generator */

#include <stdio.h>
#include <string.h>

#define c64_header_length 398

static unsigned char c64_archive_head[]= { 
	0x01, 0x08, 0x00, 0x19, 0xcd, 0x07, 0x9e, 0xc2, 
	0x28, 0x34, 0x33, 0x29, 0xaa, 0x32, 0x35, 0x36, 
	0xac, 0xc2, 0x28, 0x34, 0x34, 0x29, 0xaa, 0x32, 
	0x36, 0x00, 0x00, 0x00, 0xa0, 0x00, 0xa5, 0x2b, 
	0x85, 0x02, 0xa5, 0x2c, 0x85, 0x03, 0xb1, 0x02, 
	0x99, 0x01, 0xce, 0xc8, 0xd0, 0xf8, 0xe6, 0x03, 
	0xb1, 0x02, 0x99, 0x01, 0xcf, 0xc8, 0xd0, 0xf8, 
	0x4c, 0x47, 0xce, 0x78, 0xa6, 0x01, 0xa9, 0x00, 
	0x85, 0x01, 0xb1, 0x02, 0x86, 0x01, 0x58, 0x60, 
	0xb9, 0x27, 0xcf, 0xc8, 0x20, 0xd2, 0xff, 0xd0, 
	0xf7, 0x18, 0xa5, 0x02, 0x69, 0x8c, 0x85, 0x02, 
	0xa5, 0x03, 0x69, 0x00, 0x85, 0x03, 0xa0, 0x00, 
	0x84, 0xfb, 0x20, 0x3a, 0xce, 0xd0, 0x0a, 0xb9, 
	0x86, 0xcf, 0xc8, 0x20, 0xd2, 0xff, 0xd0, 0xf7, 
	0x60, 0xb9, 0x58, 0xcf, 0xc8, 0x20, 0xd2, 0xff, 
	0xd0, 0xf7, 0xa0, 0x00, 0x20, 0x3a, 0xce, 0xf0, 
	0x09, 0x99, 0x00, 0xce, 0x20, 0xd2, 0xff, 0xc8, 
	0xd0, 0xf2, 0x98, 0xa2, 0x00, 0xa0, 0xce, 0x20, 
	0xbd, 0xff, 0xa9, 0x01, 0xa6, 0xba, 0xa0, 0x01, 
	0x20, 0xba, 0xff, 0x20, 0xc0, 0xff, 0xb0, 0x49, 
	0xa2, 0x01, 0x20, 0xc9, 0xff, 0xb0, 0x42, 0xa4, 
	0xb7, 0xc8, 0x20, 0x3a, 0xce, 0x85, 0x04, 0xc8, 
	0x20, 0x3a, 0xce, 0x85, 0x05, 0x38, 0x98, 0x65, 
	0x02, 0x85, 0x02, 0xa0, 0x00, 0x90, 0x02, 0xe6, 
	0x03, 0xc4, 0x04, 0xd0, 0x04, 0xa5, 0x05, 0xf0, 
	0x16, 0x20, 0x3a, 0xce, 0x20, 0xd2, 0xff, 0xb0, 
	0x18, 0x65, 0xfb, 0x85, 0xfb, 0xc8, 0xd0, 0xe9, 
	0xe6, 0x03, 0xc6, 0x05, 0x4c, 0xc0, 0xce, 0x20, 
	0xcc, 0xff, 0xa9, 0x01, 0x20, 0xc3, 0xff, 0x90, 
	0x14, 0x20, 0xcc, 0xff, 0xa9, 0x01, 0x20, 0xc3, 
	0xff, 0xa0, 0x00, 0xb9, 0x42, 0xcf, 0xc8, 0x20, 
	0xd2, 0xff, 0xd0, 0xf7, 0x60, 0x20, 0x3a, 0xce, 
	0xc5, 0xfb, 0xf0, 0x0c, 0xa0, 0x00, 0xb9, 0x64, 
	0xcf, 0xc8, 0x20, 0xd2, 0xff, 0xd0, 0xf7, 0x60, 
	0x38, 0x98, 0x65, 0x02, 0x85, 0x02, 0x90, 0x02, 
	0xe6, 0x03, 0xa0, 0x00, 0xb9, 0x7f, 0xcf, 0xc8, 
	0x20, 0xd2, 0xff, 0xd0, 0xf7, 0x4c, 0x5d, 0xce, 
	0x53, 0x45, 0x4c, 0x46, 0x20, 0x45, 0x58, 0x54, 
	0x52, 0x41, 0x43, 0x49, 0x4e, 0x47, 0x20, 0x41, 
	0x52, 0x43, 0x48, 0x49, 0x56, 0x45, 0x2e, 0x2e, 
	0x2e, 0x0d, 0x00, 0x20, 0x28, 0x49, 0x2f, 0x4f, 
	0x20, 0x45, 0x52, 0x52, 0x4f, 0x52, 0x29, 0x0d, 
	0x53, 0x54, 0x4f, 0x50, 0x50, 0x45, 0x44, 0x0d, 
	0x00, 0x45, 0x58, 0x54, 0x52, 0x41, 0x43, 0x54, 
	0x49, 0x4e, 0x47, 0x20, 0x00, 0x20, 0x28, 0x43, 
	0x48, 0x45, 0x43, 0x4b, 0x53, 0x55, 0x4d, 0x20, 
	0x45, 0x52, 0x52, 0x4f, 0x52, 0x29, 0x0d, 0x53, 
	0x54, 0x4f, 0x50, 0x50, 0x45, 0x44, 0x0d, 0x00, 
	0x20, 0x28, 0x4f, 0x4b, 0x29, 0x0d, 0x00, 0x44, 
	0x4f, 0x4e, 0x45, 0x2e, 0x0d, 0x00 };
	
void
main(int argc, char **argv)
{
  FILE *outfile;
  FILE *infile;
  int i,j,p;
  unsigned long total;
  char  tmp;
  unsigned char sum;
  int conv_flag;
  char *ctmp;
  char *format;
  
  if (argc<4) {
    /* print howto */
    printf("usage: %s format outfile infiles...\n"
	   "  infile-names prefixed with * will be converted into\n"
	   "  propretary machine-bios-native format\n"
	   "  supported formats: c64, c128\n",argv[0]);
    exit(1);
  }

  format=argv[1];
  if (strcmp(format,"c64") && strcmp(format,"c128")) {
    fprintf(stderr,"%s: unsupported target \"%s\"\n",argv[0],format);
    exit(1); }

  outfile=fopen(argv[2],"w");
  if (outfile==NULL) {
    printf("can't open output file \"%s\".\n",argv[2]);
    exit(1); }
  
  i=0;
  while (i<c64_header_length) 
    fputc(c64_archive_head[i++], outfile);
  total=c64_header_length+0x0801;
    
  /* check for dupplicate filenames */
  i=4; p=0;
  while (i<argc) {
    j=3;
    while (j<i) {
      if (!strcmp(argv[i],argv[j])) {
	printf("%s:error: dupplicate filename \"%s\"\n",argv[0],argv[i]);
	p++;
      }
      j++;
    }
    i++;
  }
  if (p>0)
    exit(1);


  i=3;  
  while (i<argc) {
    sum=0;
    ctmp=argv[i];
    if (*ctmp=='*') ctmp++;
    /* printf("adding \"%s\" ",ctmp); */
    infile=fopen(ctmp,"r");
    if (infile==NULL) {
      printf("\ncan't open file\n");
      exit(1); }
    j=0;
    while (fgetc(infile)!=EOF) j++;
    rewind(infile);
    /* printf("(%i bytes)\n",j); */
    p=0;
    conv_flag=0;
    do {
      tmp=argv[i][p];
      if (tmp=='*') { conv_flag=1; p++; continue; }
      if (conv_flag) {
        if (tmp>='a' && tmp<='z') tmp=tmp-'a'+'A';
        else if (tmp>='A' && tmp<='Z') tmp=tmp-'A'+'a';
        }
      fputc(tmp,outfile);
      p++; }
    while (tmp!='\0');
    fputc(j & 0x00ff,outfile);
    fputc(j >> 8, outfile);
    total+=p+2;
    while ((j=fgetc(infile))!=EOF) {
      fputc(j,outfile);
      total++;
      sum+=j; }
    fputc(sum & 0xff, outfile);
    total++;
    fclose(infile);
    i++; }
  fputc(0,outfile);
  total++;
  fclose(outfile);
  if (total>0xCE00) {
    printf("error: archive too large\n");
    exit(1); } 
  exit(0);
}


