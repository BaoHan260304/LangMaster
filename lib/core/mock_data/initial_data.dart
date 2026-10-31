import '../models/flashcard_model.dart';
import '../models/topic_model.dart';

class InitialData {
  static List<FlashcardModel> get sampleFlashcards => getAllFlashcards();
  static List<TopicModel> get sampleTopics => getTopics();

  static List<TopicModel> getTopics() {
    return [
      TopicModel(
        id: 't1',
        title: 'Giao tiếp cơ bản',
        description: 'Từ vựng thông dụng hàng ngày cho người mới bắt đầu',
        flashcardCount: 4,
        iconName: 'chat',
        isCustom: false,
      ),
      TopicModel(
        id: 't2',
        title: 'IELTS Academic 7.0+',
        description: 'Từ vựng học thuật đỉnh cao kèm phát âm và Video ngữ cảnh',
        flashcardCount: 4,
        iconName: 'school',
        isCustom: false,
      ),
      TopicModel(
        id: 't3',
        title: 'Tiếng Anh Thương Mại',
        description: 'Giao tiếp công sở, đàm phán hợp đồng và thuyết trình',
        flashcardCount: 4,
        iconName: 'business_center',
        isCustom: false,
      ),
      TopicModel(
        id: 't4',
        title: 'Du lịch & Khám phá',
        description: 'Đặt phòng, gọi món và chỉ đường tại sân bay quốc tế',
        flashcardCount: 4,
        iconName: 'flight_takeoff',
        isCustom: false,
      ),
    ];
  }

  static List<FlashcardModel> getAllFlashcards() {
    return [
      // ===== TOPIC 1: GIAO TIẾP CƠ BẢN =====
      FlashcardModel(
        id: 'f1',
        topicId: 't1',
        word: 'Greeting',
        phonetic: '/ˈɡriː.tɪŋ/',
        meaning: 'Lời chào hỏi, sự chào đón',
        example: 'A warm greeting makes everyone feel comfortable.',
        imageUrl:
            'https://images.unsplash.com/photo-1543269865-cbf427effbad?auto=format&fit=crop&w=600&q=80',
        audioUrl:
            'https://ssl.gstatic.com/dictionary/static/sounds/oxford/greeting--_gb_1.mp3',
        videoUrl:
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
      ),
      FlashcardModel(
        id: 'f2',
        topicId: 't1',
        word: 'Gratitude',
        phonetic: '/ˈɡræt.ɪ.tʃuːd/',
        meaning: 'Lòng biết ơn, sự tri ân',
        example: 'She expressed her deep gratitude for their support.',
        imageUrl:
            'https://images.unsplash.com/photo-1518495973542-4542c06a5843?auto=format&fit=crop&w=600&q=80',
        audioUrl:
            'https://ssl.gstatic.com/dictionary/static/sounds/oxford/gratitude--_gb_1.mp3',
        videoUrl: null,
      ),
      FlashcardModel(
        id: 'f3',
        topicId: 't1',
        word: 'Apology',
        phonetic: '/əˈpɒl.ə.dʒi/',
        meaning: 'Lời xin lỗi chân thành',
        example: 'We owe you a sincere apology for the delay.',
        imageUrl:
            'https://images.unsplash.com/photo-1499209974431-9dddcece7f88?auto=format&fit=crop&w=600&q=80',
        audioUrl:
            'https://ssl.gstatic.com/dictionary/static/sounds/oxford/apology--_gb_1.mp3',
        videoUrl: null,
      ),
      FlashcardModel(
        id: 'f4',
        topicId: 't1',
        word: 'Friendship',
        phonetic: '/ˈfrend.ʃɪp/',
        meaning: 'Tình bạn, tình hữu nghị',
        example: 'True friendship withstands the test of time.',
        imageUrl:
            'https://images.unsplash.com/photo-1529156069898-49953e39b3ac?auto=format&fit=crop&w=600&q=80',
        audioUrl:
            'https://ssl.gstatic.com/dictionary/static/sounds/oxford/friendship--_gb_1.mp3',
        videoUrl: null,
      ),

      // ===== TOPIC 2: IELTS ACADEMIC 7.0+ =====
      FlashcardModel(
        id: 'f5',
        topicId: 't2',
        word: 'Resilient',
        phonetic: '/rɪˈzɪl.jənt/',
        meaning: 'Kiên cường, có khả năng phục hồi nhanh',
        example: 'Local communities proved resilient in the face of hardship.',
        imageUrl:
            'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?auto=format&fit=crop&w=600&q=80',
        audioUrl:
            'https://ssl.gstatic.com/dictionary/static/sounds/oxford/resilient--_gb_1.mp3',
        videoUrl:
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      ),
      FlashcardModel(
        id: 'f6',
        topicId: 't2',
        word: 'Ubiquitous',
        phonetic: '/juːˈbɪk.wɪ.təs/',
        meaning: 'Có mặt ở khắp mọi nơi, phổ biến rộng rãi',
        example: 'Smartphones have become ubiquitous in modern society.',
        imageUrl:
            'https://images.unsplash.com/photo-1451187580459-43490279c0fa?auto=format&fit=crop&w=600&q=80',
        audioUrl:
            'https://ssl.gstatic.com/dictionary/static/sounds/oxford/ubiquitous--_gb_1.mp3',
        videoUrl: null,
      ),
      FlashcardModel(
        id: 'f7',
        topicId: 't2',
        word: 'Ephemeral',
        phonetic: '/ɪˈfem.ər.əl/',
        meaning: 'Phù du, chóng tàn, ngắn ngủi',
        example: 'Fame in modern pop culture is often ephemeral.',
        imageUrl:
            'https://images.unsplash.com/photo-1499346030926-9a72daac6c63?auto=format&fit=crop&w=600&q=80',
        audioUrl:
            'https://ssl.gstatic.com/dictionary/static/sounds/oxford/ephemeral--_gb_1.mp3',
        videoUrl: null,
      ),
      FlashcardModel(
        id: 'f8',
        topicId: 't2',
        word: 'Meticulous',
        phonetic: '/məˈtɪk.jə.ləs/',
        meaning: 'Tỉ mỉ, cẩn thận, chu đáo từng chi tiết',
        example: 'The research project required meticulous planning.',
        imageUrl:
            'https://images.unsplash.com/photo-1434030216411-0b793f4b4173?auto=format&fit=crop&w=600&q=80',
        audioUrl:
            'https://ssl.gstatic.com/dictionary/static/sounds/oxford/meticulous--_gb_1.mp3',
        videoUrl: null,
      ),

      // ===== TOPIC 3: TIẾNG ANH THƯƠNG MẠI =====
      FlashcardModel(
        id: 'f9',
        topicId: 't3',
        word: 'Negotiate',
        phonetic: '/nəˈɡəʊ.ʃi.eɪt/',
        meaning: 'Đàm phán, thương lượng hợp đồng',
        example: 'We managed to negotiate a favorable deal for both parties.',
        imageUrl:
            'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=600&q=80',
        audioUrl:
            'https://ssl.gstatic.com/dictionary/static/sounds/oxford/negotiate--_gb_1.mp3',
        videoUrl:
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
      ),
      FlashcardModel(
        id: 'f10',
        topicId: 't3',
        word: 'Pragmatic',
        phonetic: '/præɡˈmæt.ɪk/',
        meaning: 'Thực tế, thực dụng, chú trọng tính khả thi',
        example: 'He adopted a pragmatic approach to solve financial problems.',
        imageUrl:
            'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?auto=format&fit=crop&w=600&q=80',
        audioUrl:
            'https://ssl.gstatic.com/dictionary/static/sounds/oxford/pragmatic--_gb_1.mp3',
        videoUrl: null,
      ),
      FlashcardModel(
        id: 'f11',
        topicId: 't3',
        word: 'Innovation',
        phonetic: '/ˌɪn.əˈveɪ.ʃən/',
        meaning: 'Sự đổi mới, sáng kiến công nghệ đột phá',
        example: 'Innovation is the driving force behind economic growth.',
        imageUrl:
            'https://images.unsplash.com/photo-1485827404703-89b55fcc595e?auto=format&fit=crop&w=600&q=80',
        audioUrl:
            'https://ssl.gstatic.com/dictionary/static/sounds/oxford/innovation--_gb_1.mp3',
        videoUrl: null,
      ),
      FlashcardModel(
        id: 'f12',
        topicId: 't3',
        word: 'Revenue',
        phonetic: '/ˈrev.ən.juː/',
        meaning: 'Doanh thu, lợi tức của doanh nghiệp',
        example: 'Company revenue increased by 20% in the third quarter.',
        imageUrl:
            'https://images.unsplash.com/photo-1559526324-4b87b5e36e44?auto=format&fit=crop&w=600&q=80',
        audioUrl:
            'https://ssl.gstatic.com/dictionary/static/sounds/oxford/revenue--_gb_1.mp3',
        videoUrl: null,
      ),

      // ===== TOPIC 4: DU LỊCH & KHÁM PHÁ =====
      FlashcardModel(
        id: 'f13',
        topicId: 't4',
        word: 'Itinerary',
        phonetic: '/aɪˈtɪn.ər.ər.i/',
        meaning: 'Lịch trình chuyến đi, hành trình du lịch',
        example: 'Please check the itinerary before departing for Paris.',
        imageUrl:
            'https://images.unsplash.com/photo-1488646953014-85cb44e25828?auto=format&fit=crop&w=600&q=80',
        audioUrl:
            'https://ssl.gstatic.com/dictionary/static/sounds/oxford/itinerary--_gb_1.mp3',
        videoUrl: null,
      ),
      FlashcardModel(
        id: 'f14',
        topicId: 't4',
        word: 'Destination',
        phonetic: '/ˌdes.tɪˈneɪ.ʃən/',
        meaning: 'Điểm đến, đích đến của hành trình',
        example: 'Da Nang is an attractive destination for foreign tourists.',
        imageUrl:
            'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=600&q=80',
        audioUrl:
            'https://ssl.gstatic.com/dictionary/static/sounds/oxford/destination--_gb_1.mp3',
        videoUrl: null,
      ),
      FlashcardModel(
        id: 'f15',
        topicId: 't4',
        word: 'Hospitality',
        phonetic: '/ˌhɒs.pɪˈtæl.ə.ti/',
        meaning: 'Lòng hiếu khách, ngành dịch vụ khách sạn',
        example: 'We were deeply touched by the warm hospitality of the locals.',
        imageUrl:
            'https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=600&q=80',
        audioUrl:
            'https://ssl.gstatic.com/dictionary/static/sounds/oxford/hospitality--_gb_1.mp3',
        videoUrl: null,
      ),
      FlashcardModel(
        id: 'f16',
        topicId: 't4',
        word: 'Souvenir',
        phonetic: '/ˌsuː.vənˈɪər/',
        meaning: 'Vật kỷ niệm, món quà lưu niệm',
        example: 'I bought a handcrafted souvenir at the night market.',
        imageUrl:
            'https://images.unsplash.com/photo-1513519245088-0e12902e5a38?auto=format&fit=crop&w=600&q=80',
        audioUrl:
            'https://ssl.gstatic.com/dictionary/static/sounds/oxford/souvenir--_gb_1.mp3',
        videoUrl: null,
      ),
    ];
  }

  static List<FlashcardModel> getFlashcardsByTopic(String topicId) {
    return getAllFlashcards().where((card) => card.topicId == topicId).toList();
  }
}

