class AxmpayTermsList {
  final List<TermSection>? data;

  AxmpayTermsList({
    required this.data,
  });

  factory AxmpayTermsList.fromJson(Map<String, dynamic> json) {
    return AxmpayTermsList(
      data: (json['data'] as List).map((item) => TermSection.fromJson(item)).toList(),
    );
  }
}

class TermSection {
  final String sectionNumber;
  final String content;
  final String parentSection;
  final String dateAdded;

  TermSection({
    required this.sectionNumber,
    required this.content,
    required this.parentSection,
    required this.dateAdded,
  });

  factory TermSection.fromJson(Map<String, dynamic> json) {
    return TermSection(
      sectionNumber: json['sectionNumber'],
      content: json['content'],
      parentSection: json['parentSection'],
      dateAdded: json['date_added'],
    );
  }
}

class AxmpayFaq {
  final int id;
  final String question;
  final String answer;
  final String date;

  AxmpayFaq({
    required this.id,
    required this.question,
    required this.answer,
    required this.date,
  });

  factory AxmpayFaq.fromJson(Map<String, dynamic> json) {
    return AxmpayFaq(
      id: json['id'],
      question: json['question'],
      answer: json['answer'],
      date: json['date'],
    );
  }
}

class AxmpayFaqList {
  final List<AxmpayFaq>? faqs;

  AxmpayFaqList({required this.faqs});

  factory AxmpayFaqList.fromJson(Map<String, dynamic> json) {
    List<dynamic> faqsList = json['faqs'] ?? [];
    return AxmpayFaqList(
      faqs: faqsList.map((item) => AxmpayFaq.fromJson(item)).toList(),
    );
  }
}