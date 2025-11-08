#include <zlib.h>

#include <string>
#include <tuple>
#include <stdexcept>
#include <memory>

std::tuple<std::unique_ptr<const unsigned char>, size_t, size_t> applib_compress(const std::string& str)
{
   uLongf zip_size = compressBound(static_cast<uLongf>(str.length()));

   std::unique_ptr<unsigned char> zip_buf(new unsigned char[zip_size]);

   if(compress(zip_buf.get(), &zip_size, reinterpret_cast<const Bytef*>(str.c_str()), static_cast<uLongf>(str.length())) != Z_OK)
      throw std::runtime_error("Cannot compress a buffer");

   return std::make_tuple(std::move(zip_buf), static_cast<size_t>(zip_size), str.length());
}

std::string applib_uncompress(std::tuple<std::unique_ptr<const unsigned char>, size_t, size_t> compressed)
{
   uLongf unzip_size = static_cast<uLongf>(std::get<2>(compressed));

   std::unique_ptr<unsigned char> unzip_buf(new unsigned char[std::get<2>(compressed)]);

   if(uncompress(unzip_buf.get(), &unzip_size, std::get<0>(compressed).get(), static_cast<uLongf>(std::get<1>(compressed))) != Z_OK)
      throw std::runtime_error("Cannot uncompress a buffer");

   return std::string(reinterpret_cast<char*>(unzip_buf.release()), std::get<2>(compressed));
}
