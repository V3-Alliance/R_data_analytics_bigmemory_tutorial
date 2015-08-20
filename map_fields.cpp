/* gcc -W map_fields.cpp -o map_fields */
/* Run it with: $ ./map_fields [source-filename] [destination_filename] */

#include <iostream>
#include <fstream>
#include <sstream>

#include <boost/fusion/adapted/boost_tuple.hpp>
#include <boost/fusion/sequence/io.hpp>

namespace fusion = boost::fusion;

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
        
        char* source_file_name = argv[1];
        std::cout << "Source file path: " <<  source_file_name <<  std::endl;
        std::ifstream source_file(source_file_name);
        if (!source_file.is_open())
        {
            std::cout << "Null input file pointer from path: " <<  source_file <<  std::endl;
            return 1;
        }

        char* destination_file_name = argv[2];
        std::cout << "Destination file path: " <<  destination_file_name <<  std::endl;
        std::ofstream destination_file(destination_file_name);
        if (!destination_file.is_open())
        {
            std::cout << "Null output file pointer from path: " <<  destination_file <<  std::endl;
            return 1;
        }
        
        std::string line;
        long line_count = 0;
        while ( std::getline (source_file, line) )
        {
          destination_file << line << std::endl;
          line_count++;
        }
        
        std::cout << "Line count: " << line_count <<  std::endl;

        source_file.close();
        destination_file.close();

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
        std::cout << "Use: ./map_fields [source-filename] [destination_filename]" <<  std::endl;
        return 1;
    }
}