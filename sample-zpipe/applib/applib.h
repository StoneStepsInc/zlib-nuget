#ifndef APPLIB_H
#define APPLIB_H

#include <string>
#include <tuple>
#include <memory>

// returns {compressed-bytes, compressed-size, original-size}
std::tuple<std::unique_ptr<const unsigned char>, size_t, size_t> applib_compress(const std::string& str);

// takes the tuple returned from the function above
std::string applib_uncompress(std::tuple<std::unique_ptr<const unsigned char>, size_t, size_t> compressed);

#endif

