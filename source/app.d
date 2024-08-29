import std.stdio;

uint utf8_to_ucs2(string src) {
  int i = 0;
  ulong len = src.length;

  if((src[i] & 0b1000_0000) == 0b0000_0000) {
    // 해당하는 값은 ASCII 코드이다.
    return cast(uint)src[i];
  } else if((src[i] & 0b1110_0000) == 0b1100_0000) {
    // 2바이트 글자
    if( (i + 1) > len) {
      return 0;
    }

    auto a = cast(ubyte)(src[i]     & 0b0001_1111);
    auto b = cast(ubyte)(src[i + 1] & 0b0011_1111);
    
    return (a << 6) | b;
  } else if(( src[i] & 0b1111_0000) == 0b1110_0000) {
    // 3 바이트 글자
    if(((i+2) >= len) || ((i+1) >= len)) {
      return 0;
    }

    auto a = cast(ubyte)(src[i]    & 0b0000_1111);
    auto b = cast(ubyte)(src[i+1]  & 0b0011_1111);
    auto c = cast(ubyte)(src[i+2]  & 0b0011_1111);

    return a << 12 | b << 6 | c;
  } 

  return 0;

}

void main()
{
  import std.format;


  string statement = "가";

  writeln(format("%s %x", statement, utf8_to_ucs2(statement)));

}
