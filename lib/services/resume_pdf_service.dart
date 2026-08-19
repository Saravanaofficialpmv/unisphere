import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:unisphere/models/student_resume_model.dart';

class ResumePdfService {
  static const PdfColor colorNavy = PdfColor.fromInt(0xFF1A2A4A);
  static const PdfColor colorSlate = PdfColor.fromInt(0xFF55657A);
  static const PdfColor colorBody = PdfColor.fromInt(0xFF1A1A1A);
  static const PdfColor colorAccentBlue = PdfColor.fromInt(0xFF1F6FEB);
  static const PdfColor colorDivider = PdfColor.fromInt(0xFFCBD5E1);

  /// Generates the complete A4 PDF byte array matching the reference docx structure
  static Future<Uint8List> generatePdfBytes(StudentResumeModel resume) async {
    final pdf = pw.Document();

    final dateFormat = DateFormat('dd MMM yyyy');
    final formattedDate = dateFormat.format(resume.lastUpdatedAt);

    String cleanLinkedin = (resume.header.linkedinUrl ?? 'linkedin.com/in/saravana-selvaraju')
        .replaceAll('https://', '')
        .replaceAll('http://', '')
        .replaceAll('www.', '');
    if (cleanLinkedin.endsWith('/')) cleanLinkedin = cleanLinkedin.substring(0, cleanLinkedin.length - 1);

    String cleanGithub = (resume.header.githubUrl ?? 'github.com/Saravanaofficialpmv')
        .replaceAll('https://', '')
        .replaceAll('http://', '')
        .replaceAll('www.', '');
    if (cleanGithub.endsWith('/')) cleanGithub = cleanGithub.substring(0, cleanGithub.length - 1);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 36, vertical: 32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // ── HEADER ──
              pw.Center(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      resume.header.fullName.toUpperCase(),
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        color: colorNavy,
                        letterSpacing: 0.5,
                      ),
                    ),
                    pw.SizedBox(height: 3),
                    pw.Text(
                      resume.header.headline.contains('|')
                          ? resume.header.headline
                          : 'Software Developer  |  AI Engineer  |  Data Scientist',
                      style: pw.TextStyle(
                        fontSize: 10.5,
                        fontWeight: pw.FontWeight.bold,
                        color: colorSlate,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      '${resume.header.collegeEmail}   |   ${resume.header.phone ?? "+91-8220537987"}   |   $cleanLinkedin   |   $cleanGithub',
                      style: const pw.TextStyle(
                        fontSize: 8.8,
                        color: colorBody,
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 12),

              // ── 1. PROFESSIONAL SUMMARY ──
              if (resume.professionalSummary.isNotEmpty) ...[
                _buildSectionHeading('PROFESSIONAL SUMMARY'),
                pw.Text(
                  resume.professionalSummary,
                  style: const pw.TextStyle(
                    fontSize: 8.8,
                    color: colorBody,
                    lineSpacing: 1.5,
                  ),
                  textAlign: pw.TextAlign.justify,
                ),
                pw.SizedBox(height: 10),
              ],

              // ── 2. EDUCATION ──
              if (resume.hasEducation) ...[
                _buildSectionHeading('EDUCATION'),
                ...resume.education.map((e) => pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 6),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            e.degree,
                            style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: colorNavy),
                          ),
                          pw.SizedBox(height: 1.5),
                          pw.Text(
                            '${e.institution}   |   ${e.period}  (Currently Pursuing)',
                            style: const pw.TextStyle(fontSize: 8.8, color: colorSlate),
                          ),
                          pw.SizedBox(height: 1.5),
                          pw.RichText(
                            text: pw.TextSpan(
                              children: [
                                pw.TextSpan(
                                  text: 'Relevant Coursework: ',
                                  style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: colorNavy),
                                ),
                                const pw.TextSpan(
                                  text: 'Machine Learning & Deep Learning  ·  Data Structures & Algorithms  ·  Database Management Systems  ·  Cloud Computing & Distributed Systems',
                                  style: pw.TextStyle(fontSize: 8.5, color: colorBody),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
                pw.SizedBox(height: 6),
              ],

              // ── 3. TECHNICAL SKILLS ──
              if (resume.hasSkills) ...[
                _buildSectionHeading('TECHNICAL SKILLS'),
                ..._buildSkillsBlocks(resume),
                pw.SizedBox(height: 6),
              ],

              // ── 4. PROJECTS ──
              if (resume.hasProjects) ...[
                _buildSectionHeading('PROJECTS'),
                ...resume.projects.map((p) => pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 7),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            p.title,
                            style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: colorNavy),
                          ),
                          if (p.technologies.isNotEmpty) ...[
                            pw.SizedBox(height: 1),
                            pw.Text(
                              'Technologies: ${p.technologies.join("  ·  ")}',
                              style: const pw.TextStyle(fontSize: 8.8, color: colorSlate),
                            ),
                          ],
                          pw.SizedBox(height: 1.5),
                          pw.Text(
                            p.description,
                            style: const pw.TextStyle(fontSize: 8.8, color: colorBody),
                          ),
                          pw.SizedBox(height: 1.5),
                          ...p.outcomes.map((out) {
                            if (out.toLowerCase().startsWith('impact:')) {
                              final impactText = out.substring(7).trim();
                              return pw.Padding(
                                padding: const pw.EdgeInsets.only(top: 1.5),
                                child: pw.RichText(
                                  text: pw.TextSpan(
                                    children: [
                                      pw.TextSpan(
                                        text: 'Impact: ',
                                        style: pw.TextStyle(fontSize: 8.8, fontWeight: pw.FontWeight.bold, color: colorNavy),
                                      ),
                                      pw.TextSpan(
                                        text: impactText,
                                        style: const pw.TextStyle(fontSize: 8.8, color: colorBody),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                            return pw.Padding(
                              padding: const pw.EdgeInsets.only(top: 1),
                              child: pw.Text(
                                '• $out',
                                style: const pw.TextStyle(fontSize: 8.8, color: colorBody),
                              ),
                            );
                          }),
                        ],
                      ),
                    )),
                pw.SizedBox(height: 6),
              ],

              // ── 5. CERTIFICATIONS ──
              if (resume.hasCertifications) ...[
                _buildSectionHeading('CERTIFICATIONS'),
                ...resume.certifications.map((c) => pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 3),
                      child: pw.Text(
                        '• ${c.title}  –  ${c.provider}',
                        style: const pw.TextStyle(fontSize: 8.8, color: colorBody),
                      ),
                    )),
                pw.SizedBox(height: 8),
              ],

              // ── 6. ADDITIONAL STRENGTHS ──
              _buildSectionHeading('ADDITIONAL STRENGTHS'),
              ...resume.strengths.map((s) => pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 2.5),
                    child: pw.Text(
                      '• $s',
                      style: const pw.TextStyle(fontSize: 8.8, color: colorBody),
                    ),
                  )),

              pw.Spacer(),

              // ── FOOTER ──
              pw.Divider(color: colorDivider, thickness: 0.5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'UNISPHERE Academic Engine • Verified Institutional Resume',
                    style: pw.TextStyle(fontSize: 7.5, color: colorSlate),
                  ),
                  pw.Text(
                    'Reg: ${resume.registerNumber} • $formattedDate',
                    style: pw.TextStyle(fontSize: 7.5, color: colorSlate),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildSectionHeading(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: colorNavy,
              letterSpacing: 0.5,
            ),
          ),
          pw.SizedBox(height: 2),
          pw.Container(
            height: 1.2,
            width: double.infinity,
            color: colorAccentBlue,
          ),
          pw.SizedBox(height: 3),
        ],
      ),
    );
  }

  static List<pw.Widget> _buildSkillsBlocks(StudentResumeModel resume) {
    final List<Map<String, String>> blocks = [
      {
        'category': 'Programming Languages',
        'skills': 'Python  ·  Java  ·  SQL  ·  Dart  ·  C++',
      },
      {
        'category': 'AI / ML Technologies',
        'skills': 'Machine Learning  ·  Deep Learning  ·  NLP  ·  Data Analytics',
      },
      {
        'category': 'Database Management',
        'skills': 'SQL  ·  Database Design  ·  Query Optimisation  ·  Firebase Firestore',
      },
      {
        'category': 'Development Tools',
        'skills': 'Git  ·  VS Code  ·  Flutter  ·  Android Studio  ·  PyCharm  ·  Jupyter Notebooks',
      },
      {
        'category': 'Core Competencies',
        'skills': 'Algorithm Design  ·  Data Visualisation  ·  OOP  ·  SDLC  ·  Problem Solving',
      },
    ];

    return blocks.map((b) {
      return pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 4),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              b['category']!,
              style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: colorNavy),
            ),
            pw.Text(
              b['skills']!,
              style: const pw.TextStyle(fontSize: 8.8, color: colorBody),
            ),
          ],
        ),
      );
    }).toList();
  }

  /// Direct trigger to open native system print / PDF preview dialog
  static Future<void> printOrExportResume(StudentResumeModel resume) async {
    final bytes = await generatePdfBytes(resume);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => bytes,
      name: '${resume.header.fullName.replaceAll(" ", "_")}_Resume.pdf',
    );
  }

  /// Direct trigger to share / export the PDF file to external applications
  static Future<void> shareResumePdf(StudentResumeModel resume) async {
    final bytes = await generatePdfBytes(resume);
    await Printing.sharePdf(
      bytes: bytes,
      filename: '${resume.header.fullName.replaceAll(" ", "_")}_Resume.pdf',
    );
  }
}
