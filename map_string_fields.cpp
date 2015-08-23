// gcc -W map_fields.cpp -o map_fields  -stdlib=libstdc++ -lstdc++ 
// Run it with: $ ./map_fields [source-filename] [destination_filename]

// See: http://stackoverflow.com/questions/1120140/how-can-i-read-and-parse-csv-files-in-c

#include <climits>
#include <iostream>
#include <fstream>
#include <sstream>
#include <tr1/unordered_map>

#include <boost/fusion/sequence.hpp>
#include <boost/fusion/include/sequence.hpp>
#include <boost/fusion/adapted/boost_tuple.hpp>
#include <boost/fusion/sequence/io.hpp>
#include <boost/fusion/include/io.hpp>
#include <boost/tuple/tuple_io.hpp>
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

void extract_field(std::istream& input_stream, std::string& buffer)
{
	for(;;) 
	{
		int character = input_stream.peek();
		if(std::istream::traits_type::eof() == character || ',' == character || '\n' == character)
		{
			break;
		}
		buffer.push_back(character);
		input_stream.get();
	}
}

struct string_field
{
    std::string value;

    // Read a string until a CSV delimiter is found.
    friend std::istream& operator >> (std::istream& input_stream, string_field& csvs) {
		std::string buffer;
		extract_field(input_stream, buffer);
		csvs.value.assign(buffer);
        return input_stream;
    }

	// Write a csv string string.
    friend std::ostream& operator << (std::ostream& output_stream, string_field const& csvs) 
    {
        return output_stream << csvs.value;
    }
};

struct quoted_string_field
{
    std::string value;

    // Read a string until a CSV delimiter is found.
    friend std::istream& operator >> (std::istream& input_stream, quoted_string_field& csvs) {
		std::string buffer;
		extract_field(input_stream, buffer);
		csvs.value = buffer.substr(1, buffer.size() - 2);;
        return input_stream;
    }

	// Write a csv string string.
    friend std::ostream& operator << (std::ostream& output_stream, quoted_string_field const& csvs) 
    {
        return output_stream << csvs.value;
    }
};

// Looks for an 0 or positive integer value, but if it finds a "NA" it interprets it as a "-1".
struct integer_field
{
    int value;

    // Read a string until a CSV delimiter is found.
    friend std::istream& operator >> (std::istream& input_stream, integer_field& csvi) {
        csvi.value = INT_MAX;	// Default 
		std::string buffer;
		extract_field(input_stream, buffer);
        if( buffer != "NA" )
        {
        	csvi.value = boost::lexical_cast<int>(buffer);
        }
        return input_stream;
    }

	// Write a csv integer string.
    friend std::ostream& operator << (std::ostream& output_stream, integer_field const& csvi) 
    {
        return output_stream << csvi.value;
    }
};

// Looks for an 0 or positive integer value, but if it finds a "NA" it interprets it as a "-1".
template <class T>
struct lookup_field
{
    int value;
    static std::tr1::unordered_map<std::string, int> s_lookup_table;
    
    // Read a string until a CSV delimiter is found.
    friend std::istream& operator >> (std::istream& input_stream, lookup_field& csvi) {
        csvi.value = INT_MAX;	// Default 
		std::string buffer;
		extract_field(input_stream, buffer);
        if( buffer != "NA" )
        {
         	std::tr1::unordered_map<std::string, int>::const_iterator item_location = lookup_field::s_lookup_table.find(buffer);
         	if (item_location != lookup_field::s_lookup_table.end())
         	{
        		csvi.value = item_location->second;
         	}
        }
        return input_stream;
    }

	// Write a csv integer string.
    friend std::ostream& operator << (std::ostream& output_stream, lookup_field const& csvi) 
    {
        return output_stream << csvi.value;
    }
};

template <class T>
std::tr1::unordered_map<std::string, int> lookup_field<T>::s_lookup_table = std::tr1::unordered_map<std::string, int>();

struct unique_carrier_id {};
struct aircraft_id {};


void load_carriers(std::ifstream& carrier_file, std::tr1::unordered_map<std::string, int>& carrier_indices)
{
	typedef quoted_string_field code;
	typedef std::string description;
    typedef fusion::vector<code, description> carrier_details;

	std::string aline;
	carrier_details carrier;
	long carrier_count = 0;
	
	while ( std::getline (carrier_file, aline) )
	{
		if (carrier_count == 0)
		{
			// Ignore header line: Code, Description       		
		} 
		else
		{
			// Process the CSV rows.
			
			std::stringstream row(aline);
			using fusion::operator >>;
    		using fusion::at_c;
			row  >> fusion::tuple_open("") << fusion::tuple_close("") << fusion::tuple_delimiter(',') >> carrier;
			carrier_indices[at_c<0>(carrier).value] = carrier_count;
		}

		carrier_count++;
	}
	
	std::cout << "Carrier count: " << carrier_count - 1 <<  std::endl;
}

void load_aircraft(std::ifstream& aircraft_file, std::tr1::unordered_map<std::string, int>& aircraft_indices)
{
	typedef string_field code;
	typedef std::string description;
    typedef fusion::vector<code, description> aircraft_details;

	std::string aline;
	aircraft_details aircraft;
	long aircraft_count = 0;
	
	while ( std::getline (aircraft_file, aline) )
	{
		if (aircraft_count == 0)
		{
			// Ignore header line: Code, Description       		
		} 
		else
		{
			// Process the CSV rows.
			
			std::stringstream row(aline);
			using fusion::operator >>;
    		using fusion::at_c;
			row  >> fusion::tuple_open("") << fusion::tuple_close("") << fusion::tuple_delimiter(',') >> aircraft;
			aircraft_indices[at_c<0>(aircraft).value] = aircraft_count;
		}

		aircraft_count++;
	}
	
	std::cout << "Aircraft count: " << aircraft_count - 1 <<  std::endl;
}

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

	Name	Description
	1	Year				1987-2008
	2	Month				1-12
	3	DayofMonth			1-31
	4	DayOfWeek			1 (Monday) - 7 (Sunday)
	5	DepTime				actual departure time (local, hhmm)
	6	CRSDepTime			scheduled departure time (local, hhmm)
	7	ArrTime				actual arrival time (local, hhmm)
	8	CRSArrTime			scheduled arrival time (local, hhmm)
	
	9	UniqueCarrier		unique carrier code
	10	FlightNum			flight number, looks like 
	11	TailNum				plane tail number
	12	ActualElapsedTime	in minutes
	13	CRSElapsedTime		in minutes
	14	AirTime				in minutes
	15	ArrDelay			arrival delay, in minutes
	16	DepDelay			departure delay, in minutes
	
	17	Origin				origin IATA airport code
	18	Dest				destination IATA airport code
	19	Distance			in miles
	20	TaxiIn				taxi in time, in minutes
	21	TaxiOut				taxi out time in minutes
	
	22	Cancelled			was the flight cancelled?
	23	CancellationCode	reason for cancellation (A = carrier, B = weather, C = NAS, D = security)
	24	Diverted			1 = yes, 0 = no
	25	CarrierDelay		in minutes
	26	WeatherDelay		in minutes
	27	NASDelay			in minutes
	28	SecurityDelay		in minutes
	
	29	LateAircraftDelay	in minutes
		
Example data for one line of csv file.
The layout matches the typedefs for field groups below.
	1987,10,14,3,741,730,912,849,
	PS,1451,NA,91,79,NA,23,11,
	SAN,SFO,447,NA,NA,
	0,NA,0,NA,NA,NA,NA,
	NA
*/
	typedef integer_field year;
	typedef integer_field month;
	typedef integer_field day_of_month;
	typedef integer_field day_of_week;
	typedef integer_field dep_time;
	typedef integer_field crs_dep_time;
	typedef integer_field arr_time;
	typedef integer_field crs_arr_time;
	
	typedef lookup_field<unique_carrier_id> unique_carrier;
	typedef integer_field flight_num;
	typedef lookup_field<aircraft_id> tail_num;
	typedef integer_field actual_elapsed_time;
	typedef integer_field crs_elapsed_time;
	typedef integer_field air_time;
	typedef integer_field arr_delay;
	typedef integer_field dep_delay;

	// Boost Fusion vector templates limited to 10 types so the 29 fields
	// are broken up into field groups, each of which is below the 10 limit.
	// Might get around it by changing
	// #define FUSION_MAX_VECTOR_SIZE 29
	// These are all string fields as the target data file has "NA" in some integer fields
	// and this causes the parse to fall out of alignment.
    typedef fusion::vector<year, month, day_of_month, day_of_week, dep_time, crs_dep_time, arr_time, crs_arr_time> csv_row0;
    typedef fusion::vector<unique_carrier, flight_num, tail_num, actual_elapsed_time, crs_elapsed_time, air_time, arr_delay, dep_delay> csv_row1;
    typedef fusion::vector<string_field, string_field, string_field, string_field, string_field> csv_row2;
    typedef fusion::vector<string_field, string_field, integer_field, integer_field, integer_field, integer_field, integer_field> csv_row3;
    typedef fusion::vector<integer_field> csv_row4;
    
	// TODO RR: Sorry! ugly mixture to c and c++ I might fix one day.
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
	
		char carrier_file_name[] = "carriers.csv";
        std::cout << "Carriers file path: " <<  carrier_file_name <<  std::endl;
        std::ifstream carrier_file(carrier_file_name);
        if (!carrier_file.is_open())
        {
            std::cout << "Null input file pointer from path: " <<  carrier_file <<  std::endl;
            return 1;
        }
	
		char aircraft_file_name[] = "plane-data.csv";
        std::cout << "Aircraft file path: " <<  aircraft_file_name <<  std::endl;
        std::ifstream aircraft_file(aircraft_file_name);
        if (!aircraft_file.is_open())
        {
            std::cout << "Null input file pointer from path: " <<  aircraft_file <<  std::endl;
            return 1;
        }
        
        std::tr1::unordered_map<std::string, int> carrier_indices;
		load_carriers(carrier_file, carrier_indices);
		unique_carrier::s_lookup_table = carrier_indices; 
		std::cout << carrier_indices.size() << std::endl;
		for (std::tr1::unordered_map<std::string, int>::iterator it = carrier_indices.begin(); it != carrier_indices.end(); ++it)
		{
			std::cout << (*it).first << "," << (*it).second << std::endl;
		}
        
        std::tr1::unordered_map<std::string, int> aircraft_indices;
		load_aircraft(aircraft_file, aircraft_indices);
		tail_num::s_lookup_table = aircraft_indices; 
		std::cout << aircraft_indices.size() << std::endl;
		for (std::tr1::unordered_map<std::string, int>::iterator it = aircraft_indices.begin(); it != aircraft_indices.end(); ++it)
		{
			std::cout << (*it).first << "," << (*it).second << std::endl;
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
        
        std::cout << "Line count: " << line_count - 1 <<  std::endl;

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

