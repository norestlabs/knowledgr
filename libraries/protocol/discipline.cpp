#include <colab/protocol/discipline.hpp>
#include <boost/rational.hpp>
#include <boost/multiprecision/cpp_int.hpp>

/*


*/

namespace colab { namespace protocol {

	static std::map<protocol::discipline_category, std::string> category_str_map;
	void discipline::set_discipline_category_str_map() {
		category_str_map[dc_unknown] = "unknown";
		category_str_map[dc_science] = "science";
		category_str_map[dc_technology] = "technology";
		category_str_map[dc_engineering] = "engineering";
		category_str_map[dc_mathematics] = "mathematics";
	}

	std::string discipline::category_str()const
	{
		if (category_str_map.size() <= 0) {
			set_discipline_category_str_map();
		}

		if ( category >= dc_unknown && category <= dc_mathematics ) return category_str_map[category];
		return "unknown";
	}

	discipline_category discipline::category_from_str(const std::string& str)
	{
		if (category_str_map.size() <= 0) {
			set_discipline_category_str_map();
		}

		std::string _str = fc::to_lower(fc::trim(str));
		for (map<discipline_category, std::string>::const_iterator i1 = category_str_map.begin(); i1 != category_str_map.end(); i1 ++) {
			if ((*i1).second == _str) {
				return (*i1).first;
			}
		}
		return dc_unknown;
	}

	std::string discipline::to_string()const
	{
		std::string result = category_str();
		char s[100];
		result += " : ";
		sprintf(s, "%d", level);
		result += s;
		return result;
	}
	discipline discipline::from_string( const std::string& from )
	{
		try
		{
			string s = fc::trim( from );
			auto dot_pos = s.find( ":" );
			discipline result;
			if( dot_pos != std::string::npos )
			{
				auto cpart = s.substr( 0, dot_pos );
				auto rpart = s.substr( dot_pos + 1, s.length() - dot_pos- 1 );
				result.category = discipline::category_from_str(cpart);
				
				sscanf(rpart.c_str(), "%d", &result.level);
			}

			return result;
		}
		FC_CAPTURE_AND_RETHROW( (from) )
	}

} } // colab::protocol
