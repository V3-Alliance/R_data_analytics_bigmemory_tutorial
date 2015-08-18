/* gcc -W clean_to_ascii.c -o clean_to_ascii */
/* Run it with: $ ./clean_to_ascii [source-filename] [destination_filename] */

#include <ctype.h>
#include <stdio.h>      /* printf */
#include <time.h>       /* time_t, struct tm, time, localtime, strftime */
#include <locale.h>     /* struct lconv, setlocale, localeconv */

int main(int argc, char **argv)
{
	time_t start_time;
	time_t end_time;
	struct tm * timeinfo;
	char buffer [80];
	double duration_secs;

	struct lconv * lc;

	if (argc == 3)
	{
		printf ("Locale: %s\n", setlocale(LC_ALL, NULL));
		time ( &start_time );
		timeinfo = localtime ( &start_time );
		strftime (buffer,80,"%c", timeinfo);
		printf ("Date is: %s\n", buffer);
        
		char* source_file = argv[1];
		FILE *fin = fopen(source_file, "rb");
        if (NULL == fin)
        {
            printf ("Null input file pointer from path: %s.\n", source_file);
            return 1;
        }

        char* destination_file = argv[2];
        FILE *fout = fopen(destination_file, "w");
        if (NULL == fout)
        {
            printf ("Null output file pointer from path: %s.\n", destination_file);
            return 1;
        }
        
		int c;
		while ((c = fgetc(fin)) != EOF)
		{
			if (isprint(c) || c == '\n')
			{
				fputc(c, fout);
			}
		}
        
        fclose(fin);
		fclose(fout);

		time ( &end_time );
		timeinfo = localtime ( &end_time );
		strftime (buffer, 80, "%c", timeinfo);
		printf ("Date is: %s\n",buffer);
		
		duration_secs = difftime(end_time, start_time);
		printf ("Duration/sec: %.f\n", duration_secs);

		printf ("Locale: %s\n", setlocale(LC_ALL, "") );
		return 0;
	}
	else
	{
		printf ("Use: ./clean_to_ascii [source-filename] [destination_filename]");
		return 1;
	}
}