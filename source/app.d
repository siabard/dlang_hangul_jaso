//! utf8 문자열이나 ucs2 문자열중 한글을 자소로 분리하는 라이브러리
//!
//! 지원하는 한글 자소는 아래와 같다.
//! - 초성 ㄱㄲㄴㄷㄸㄹㅁㅂㅃㅅㅆㅇㅈㅉㅊㅋㅌㅍㅎ
//! - 중성 ㅏㅐㅑㅒㅓㅔㅕㅖㅗㅘㅙㅚㅛㅜㅝㅞㅟㅠㅡㅢㅣ
//! - 종성 ㄱㄲ(ㄱㅅ)ㄴ(ㄴㅈ)(ㄴㅎ)ㄷㄹ(ㄹㄱ)(ㄹㅁ)(ㄹㅂ)(ㄹㅅ)(ㄹㅌ)(ㄹㅍ)(ㄹㅎ)ㅁㅂ(ㅂㅅ)ㅅㅆㅇㅈㅊㅋㅌㅍㅎ

import std.stdio;

struct Jaso {
  ubyte cho;
  ubyte mid;
  ubyte jong;
}

struct Bul {
  ubyte cho;
  ubyte mid;
  ubyte jong;
}

enum Languages {
  Ascii,
  Hangul,
  HangulJamo,
  Kana,
  Arrow,
  NotImplemented,
}



Languages ucs2_languages(uint code) {
  if(code >= 0 && code <= 0x007f) {
    return Languages.Ascii;
  }

  if(code >= 0xac00 && code <= 0xd7a3) {
    return Languages.Hangul;
  }

  if(code >= 0x3131 && code <= 0x3163) {
    return Languages.HangulJamo;
  }

  if(code >= 0x3040 && code <= 0x30ff) {
    return Languages.Kana;
  }

  if(code >= 0x2190 && code <= 0x2199) {
    return Languages.Arrow;
  }

  return Languages.NotImplemented;
}

immutable ubyte NUM_OF_JONG = 28;
immutable ubyte NUM_OF_MID = 21;

Jaso build_jaso(uint code) {
  if((code & 0b1000_0000_0000_0000) == 0b1000_0000_0000_0000) {
    uint hancode =code - 0xac00;
    writeln(hancode);
    ubyte jong = hancode % NUM_OF_JONG;
    ubyte mid = cast(ubyte)(((hancode - jong) / NUM_OF_JONG) % NUM_OF_MID + 1) ;
    ubyte cho = cast(ubyte)(((hancode - jong) / NUM_OF_JONG) / NUM_OF_MID + 1) ;

    return Jaso(cho, mid, jong);
  }

  return Jaso(0, 0, 0);
}

/// 8x4x4 폰트 세트에서 초성,중성,종성의 벌을 가져오기
///
///    초성
///    초성 1벌: 받침없는 'ㅏㅐㅑㅒㅓㅔㅕㅖㅣ' 와 결합
///    초성 2벌: 받침없는 'ㅗㅛㅡ'
///    초성 3벌: 받침없는 'ㅜㅠ'
///    초성 4벌: 받침없는 'ㅘㅙㅚㅢ'
///    초성 5벌: 받침없는 'ㅝㅞㅟ'
///    초성 6벌: 받침있는 'ㅏㅐㅑㅒㅓㅔㅕㅖㅣ' 와 결합
///    초성 7벌: 받침있는 'ㅗㅛㅜㅠㅡ'
///    초성 8벌: 받침있는 'ㅘㅙㅚㅢㅝㅞㅟ'
///
///    중성
///    중성 1벌: 받침없는 'ㄱㅋ' 와 결합
///    중성 2벌: 받침없는 'ㄱㅋ' 이외의 자음
///    중성 3벌: 받침있는 'ㄱㅋ' 와 결합
///    중성 4벌: 받침있는 'ㄱㅋ' 이외의 자음
///
///    종성
///    종성 1벌: 중성 'ㅏㅑㅘ' 와 결합
///    종성 2벌: 중성 'ㅓㅕㅚㅝㅟㅢㅣ'
///    종성 3벌: 중성 'ㅐㅒㅔㅖㅙㅞ'
///    종성 4벌: 중성 'ㅗㅛㅜㅠㅡ'
Bul build_bul(Jaso jaso) {
  ubyte cho = 0;
  ubyte mid = 0;
  ubyte jong = 0;

  if(jaso.jong == 0) {
    // 받침이 없는 경우 

    if((jaso.mid >= 1 && jaso.mid <= 8) || jaso.mid == 21) {
      // ㅏㅐㅑㅒㅓㅔㅕㅖㅣ
      cho = 1; 
    } else if(jaso.mid == 9 || jaso.mid == 13 || jaso.mid == 19) {
      // ㅗㅛㅡ
      cho = 2;
    } else if(jaso.mid == 14 || jaso.mid == 18) {
      // ㅜㅠ
      cho = 3;
    } else if((jaso.mid >= 10 && jaso.mid <= 12) || jaso.mid == 20) {
      // ㅘㅙㅚㅢ
      cho = 4;
    } else if(jaso.mid >= 15 && jaso.mid <= 17) {
      // ㅝㅞㅟ
      cho = 5;
    }

    if(jaso.cho >= 1 && jaso.cho <= 2) {
      // ㄱㄲ
      mid = 1;
    } else if (jaso.cho >= 3 && jaso.cho <= 19) {
      // ㄱㄲ 이외
      mid = 2;
    } else {
      mid = 0;
    }
    jong = 0;
  } else {
    // 받침이 있는 경우 
    if((jaso.mid >= 1 && jaso.mid <= 8) || jaso.mid == 21) {
      // ㅏㅐㅑㅒㅓㅔㅕㅖㅣ
      cho = 6;
    } else if (jaso.mid == 9 || jaso.mid == 13 || jaso.mid == 14 || jaso.mid == 18 || jaso.mid == 19) {
      // ㅗㅛㅜㅠㅡ
      cho = 7;
    } else if((jaso.mid >= 10 && jaso.mid <= 12) || (jaso.mid >= 15 && jaso.mid <= 17) || jaso.mid == 20) {
      // ㅘㅙㅚㅢㅝㅞㅟ
      cho = 8;
    } else {
      cho = 0;
    }
    
    if(jaso.cho >= 1 && jaso.cho <= 2) {
      // ㄱㄲ
      mid = 3;
    } else if(jaso.cho >= 3 && jaso.cho <= 19) {
      // ㄱㄲ 이외
      mid = 4;
    } else {
      mid = 0;
    }

    if(jaso.mid == 1 || jaso.mid == 3 || jaso.mid == 10) {
      // ㅏㅑㅘ
      jong = 1;
    } else if(jaso.mid == 5 || jaso.mid == 7 || jaso.mid == 12 || jaso.mid == 15 || jaso.mid == 17 || jaso.mid == 20 || jaso.mid == 21) {
      // ㅓㅕㅚㅝㅟㅢㅣ
      jong = 2;
    } else if(jaso.mid == 2 || jaso.mid == 4 || jaso.mid == 6 || jaso.mid == 8 || jaso.mid == 11 || jaso.mid == 16) {
      // ㅐㅒㅔㅖㅙㅞ
      jong = 3;
    } else if(jaso.mid == 9 || jaso.mid ==  13 || jaso.mid ==  14 || jaso.mid == 18 || jaso.mid ==  19){
      // ㅗㅛㅜㅠㅡ
      jong = 4;
    } else {
      jong = 0;
    }
  }

  return Bul(cho, mid, jong);
}

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
  import std.algorithm;
  import std.conv;
  import std.array;

  string statement = "가갸거겨난초가이쁘다";

  auto array_utf8 = statement.map!(a => a.to!string).array;
  foreach(s; array_utf8) {
    
    auto code = utf8_to_ucs2(s);
    Jaso jaso = build_jaso(code);
    Bul bul = build_bul(jaso);
    writeln(format("%s %d %d %d %d", s, code, jaso.cho, jaso.mid, jaso.jong));
    writeln(format("%d %d %d", bul.cho, bul.mid, bul.jong));
  }



}
