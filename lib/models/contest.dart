import 'package:instagram/models/prize.dart';

class Contest {
  final String uid;
  final String name;
  final String description;
  final String? topic;
  final String? rules;
  final DateTime startTime;
  final DateTime endTime;
  final String banner;
  final List<Prize> prizes;
  final String ownerId;
  final String status;

  Contest(
      {required this.uid,
      required this.name,
      required this.description,
      this.topic,
      this.rules,
      required this.startTime,
      required this.endTime,
      required this.banner,
      required this.prizes,
      required this.ownerId,
      required this.status});

  factory Contest.fromJson(Map<String, dynamic> json) {
    final prizeList = json['prizes'].cast<Map<String, dynamic>>();
    final prizes = prizeList.map((e) => Prize.fromJson(e)).toList();
    return Contest(
        uid: json['uid'],
        name: json['name'],
        description: json['description'],
        topic: json['topic'],
        rules: json['rules'],
        startTime: DateTime.parse(json['startTime']),
        endTime: DateTime.parse(json['endTime']),
        banner: json['banner'],
        prizes: prizes,
        ownerId: json['ownerId'],
        status: json['status']);
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'topic': topic,
        'rules': rules,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'banner': banner,
        'prizes': prizes.map((e) => e.toJson()).toList(),
        'ownerId': ownerId,
        'status': status
      };
}

List<Contest> contests = [
  Contest(
      uid: '1',
      name: 'Fight Bluetooth',
      topic: 'Sport',
      description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
      rules: '''Cuộc thi dành cho tất cả các tín đồ yêu du lịch trên khắp đất nước.
Đối tượng tham gia: cá nhân hoặc nhóm tối đa 5 người.
Hình ảnh dự thi phải là ảnh chụp thực tế trong lần đi du lịch gần đây nhất tại Việt Nam, không giới hạn thời gian và địa điểm.
Số lượng ảnh dự thi: mỗi thí sinh/g nhóm được nộp tối đa 5 tác phẩm.
Các bức ảnh dự thi phải được gửi về địa chỉ email của Ban Tổ chức trong thời gian từ ngày XX đến ngày XX. Bức ảnh phải được gửi dưới định dạng JPG, dung lượng không quá 5MB.
Bức ảnh dự thi phải không được chỉnh sửa quá mức, bao gồm chỉnh sửa về màu sắc, ánh sáng, tác động đến cấu trúc hình ảnh,…
Ban giám khảo sẽ lựa chọn 3 tác phẩm xuất sắc nhất dựa trên tiêu chí: sáng tạo, chất lượng, độ phù hợp với chủ đề.
Kết quả của cuộc thi sẽ được công bố trên trang web của Ban tổ chức, cùng với thông tin về các tác phẩm xuất sắc và người chiến thắng.
Ban tổ chức có quyền sử dụng các bức ảnh dự thi cho các mục đích quảng bá du lịch của Việt Nam, với sự đồng ý của tác giả.
Mọi khiếu nại về kết quả cuộc thi sẽ không được giải quyết.''',
      startTime: DateTime.now(),
      endTime: DateTime.now(),
      banner: 'https://template.canva.com/EAFUptuk_ng/1/0/400w-1WH9JphVKxI.jpg',
      prizes: [],
      ownerId: '',
      status: ContestStatus.inProgress),
  Contest(
      uid: '2',
      name: 'Fight Bluetooth 1',
      topic: 'E-Sport',
      description: 'Hi guys!',
      rules: '',
      startTime: DateTime.now(),
      endTime: DateTime.now(),
      banner: 'https://template.canva.com/EAFLtJa7Jqo/1/0/400w-zpEtWLOG01k.jpg',
      prizes: [],
      ownerId: '',
      status: ContestStatus.expired),
  Contest(
      uid: '3',
      name: 'Fight Bluetooth 2',
      topic: 'Car',
      description: 'Hi guys!',
      rules: '',
      startTime: DateTime.now(),
      endTime: DateTime.now(),
      banner: 'https://template.canva.com/EAFNQzm9QbY/1/0/400w-nJFMqTpGqo4.jpg',
      prizes: [],
      ownerId: '',
      status: ContestStatus.comingSoon),
];

class ContestStatus {
  static const String inProgress = 'In progress';

  static const String comingSoon = 'Coming soon';

  static const String expired = 'Expired';
}
