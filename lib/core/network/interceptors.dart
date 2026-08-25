import 'package:talker/talker.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';

/// 创建脱敏后的 Dio 日志拦截器。
TalkerDioLogger createNetworkLogger(Talker talker) {
  return TalkerDioLogger(
    talker: talker,
    settings: const TalkerDioLoggerSettings(
      // 鉴权头不进日志，避免 token/cookie 泄漏。
      hiddenHeaders: <String>{'authorization', 'cookie', 'set-cookie'},
    ),
  );
}
