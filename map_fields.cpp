// gcc -W map_fields.cpp -o map_fields  -stdlib=libstdc++ -lstdc++ 
// Run it with: $ ./map_fields [source-filename] [destination_filename]

// See: http://stackoverflow.com/questions/1120140/how-can-i-read-and-parse-csv-files-in-c

#include <iostream>
#include <fstream>
#include <sstream>

#include <boost/fusion/sequence.hpp>
#include <boost/fusion/include/sequence.hpp>
#include <boost/fusion/adapted/boost_tuple.hpp>
#include <boost/fusion/sequence/io.hpp>
#include <boost/fusion/include/io.hpp>
#include </usr/local/include/boost/tuple/tuple_io.hpp>
#include <boost/fusion/container.hpp>

#include <boost/fusion/container/vector.hpp>
#include <boost/fusion/include/vector.hpp>
#include <boost/fusion/container/vector/vector_fwd.hpp>
#include <boost/fusion/include/vector_fwd.hpp>
#include <boost/lexical_cast.hpp>

#include <boost/fusion/algorithm/iteration/accumulate.hpp>
#include <boost/fusion/include/accumulate.hpp>


namespace fusion = boost::fusion;

// I/O operators for a string field within a CSV formatted string.
// This is required to replace std::string for string csv fields 
// because the boost::fusion input stream parser 
// doesn't know that a comma finishes off a string field.
struct csv_field
{
    std::string value;

    // Read a string until a CSV delimiter is found.
    friend std::istream& operator >> (std::istream& input_stream, csv_field& csvs) {
        csvs.value.clear();
        for(;;) 
        {
            int character = input_stream.peek();
            if(std::istream::traits_type::eof() == character || ',' == character || '\n' == character)
            {
                break;
            }
            csvs.value.push_back(character);
            input_stream.get();
        }
        return input_stream;
    }

	// Write a csv string.
    friend std::ostream& operator << (std::ostream& output_stream, csv_field const& csvs) 
    {
        return output_stream << csvs.value;
    }
};

// TODO RR: obsolete
struct make_row
{
    typedef std::string result_type;
    
    template<typename T>
    std::string operator()(const std::string& row, const T& field) const
    {
    	//std::string delimiter = ",";
        std::string new_row = row + "," + boost::lexical_cast<std::string>(field);
        return new_row;
    }
};


int main(int argc, char **argv)
{
    time_t start_time;
    time_t end_time;
    struct tm * timeinfo;
    char buffer [80];
    double duration_secs;

    struct lconv * lc;

/*   

Field names (29 columns): 
    "Year",
	"Month",
	"DayofMonth",
	"DayOfWeek",
	"DepTime",
	"CRSDepTime",
	"ArrTime",
	"CRSArrTime",
	"UniqueCarrier",
	"FlightNum",
	"TailNum",
	"ActualElapsedTime",
	"CRSElapsedTime",
	"AirTime",
	"ArrDelay",
	"DepDelay",
	"Origin",
	"Dest",
	"Distance",
	"TaxiIn",
	"TaxiOut",
	"Cancelled",
	"CancellationCode",
	"Diverted",
	"CarrierDelay",
	"WeatherDelay",
	"NASDelay",
	"SecurityDelay",
	"LateAircraftDelay"
	
Example data for one line of csv file.
The layout matches the typedefs for field groups below.
	1987,10,14,3,741,730,912,849,
	PS,1451,NA,91,79,NA,23,11,
	SAN,SFO,447,NA,NA,
	0,NA,0,NA,NA,NA,NA,
	NA
*/

	// Boost Fusion vector templates limited to 10 types so the 29 fields
	// are broken up into field groups, each of which is below the 10 limit.
	// Might get around it by changing
	// #define FUSION_MAX_VECTOR_SIZE 29
    typedef fusion::vector<int, int, int, int, int, int, int, int> csv_row0;
    typedef fusion::vector<csv_field, int, csv_field, int, int, csv_field, int, int> csv_row1;
    typedef fusion::vector<csv_field, csv_field, int, csv_field, csv_field> csv_row2;
    typedef fusion::vector<int, csv_field, int, csv_field, csv_field, csv_field, csv_field> csv_row3;
    typedef fusion::vector<csv_field> csv_row4;
    
	// TODO RR: Sorry, ugly mixture to c and c++ I might fix one day.
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
        
        std::string aline;
		csv_row0 csv0;
		csv_row1 csv1;
		csv_row2 csv2;
		csv_row3 csv3;
		csv_row4 csv4;
        long line_count = 0;
        while ( std::getline (source_file, aline) )
        {
			if (line_count == 0)
			{
        		// Ignore header line. Just feed it though unchanged.
        		
				destination_file << aline << std::endl;
			} 
			else
			{
				// Process the CSV rows.
				
				std::stringstream row(aline);
    			using fusion::operator >>;
				row  >> fusion::tuple_open("") << fusion::tuple_close("") << fusion::tuple_delimiter(',') >> csv0;
				row.ignore(std::numeric_limits<std::streamsize>::max(), ',');
				row  >> csv1; 
				row.ignore(std::numeric_limits<std::streamsize>::max(), ',');
				row  >> csv2; 
				row.ignore(std::numeric_limits<std::streamsize>::max(), ',');
				row  >> csv3;
				row.ignore(std::numeric_limits<std::streamsize>::max(), ',');
				row  >> csv4;
				
				
				//destination_file << line << std::endl;
    			using fusion::operator <<;
				destination_file
					// Set delimiters within field groups.
					<< fusion::tuple_open("") << fusion::tuple_close("") << fusion::tuple_delimiter(',') 
					// Output field groups with "," delimiters between field groups.
					<< csv0 << ","
					<< csv1 << ","
					<< csv2 << "," 
					<< csv3 << "," 
					<< csv4 
					<< std::endl;
			}

			line_count++;
			//if (line_count == 4)
			//{
			//	return 0;
			//}
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