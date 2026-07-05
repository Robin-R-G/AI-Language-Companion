import json
import os
import textwrap
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
LOTTIE_DIR = ROOT / 'animations' / 'lottie'
VOICE_DIR = ROOT / 'animations' / 'voice-wave'
PDF_DIR = ROOT / 'certificates' / 'pdf'

LOTTIE_DIR.mkdir(parents=True, exist_ok=True)
VOICE_DIR.mkdir(parents=True, exist_ok=True)
PDF_DIR.mkdir(parents=True, exist_ok=True)


def write_lottie(path: Path, name: str, kind: str = 'pulse') -> None:
    if kind == 'pulse':
        layers = [{
            'ddd': 0,
            'ind': 1,
            'ty': 4,
            'nm': 'pulse',
            'sr': 1,
            'ks': {
                'o': {'a': 0, 'k': 100},
                'r': {'a': 0, 'k': 0},
                'p': {'a': 0, 'k': [100, 100, 0]},
                'a': {'a': 0, 'k': [0, 0, 0]},
                's': {'a': 0, 'k': [100, 100, 100]}
            },
            'ao': 0,
            'shapes': [{
                'ty': 'gr',
                'it': [
                    {'ty': 'el', 'p': {'a': 0, 'k': [0, 0]}, 's': {'a': 0, 'k': [60, 60]}, 'p': {'a': 0, 'k': [0, 0]}, 'nm': 'Ellipse 1', 'hd': False},
                    {'ty': 'fl', 'c': {'a': 0, 'k': [0.1451, 0.3647, 0.9216, 1]}, 'o': {'a': 0, 'k': 100}, 'r': 1, 'nm': 'Fill 1'}
                ],
                'nm': 'Group 1', 'np': 2, 'cix': 2, 'bm': 0, 'ix': 1, 'mn': 'ADBE Vector Group'
            }],
            'ip': 0, 'op': 60, 'st': 0
        }]
    elif kind == 'wave':
        layers = [{
            'ddd': 0,
            'ind': 1,
            'ty': 4,
            'nm': 'wave',
            'sr': 1,
            'ks': {
                'o': {'a': 0, 'k': 100},
                'r': {'a': 0, 'k': 0},
                'p': {'a': 0, 'k': [100, 100, 0]},
                'a': {'a': 0, 'k': [0, 0, 0]},
                's': {'a': 0, 'k': [100, 100, 100]}
            },
            'ao': 0,
            'shapes': [{
                'ty': 'gr',
                'it': [
                    {'ty': 'sh', 'ks': {'a': 0, 'k': {'i': [[-40, 0], [0, 0], [40, 0]], 'o': [[-40, 0], [0, 0], [40, 0]], 'v': [[-60, 0], [0, 0], [60, 0]], 'c': False}}, 'nm': 'Path 1', 'hd': False},
                    {'ty': 'st', 'c': {'a': 0, 'k': [0.1333, 0.749, 0.650, 1]}, 'o': {'a': 0, 'k': 100}, 'w': {'a': 0, 'k': 8}, 'lc': 2, 'lj': 2, 'nm': 'Stroke 1'}
                ],
                'nm': 'Group 1', 'np': 2, 'cix': 2, 'bm': 0, 'ix': 1, 'mn': 'ADBE Vector Group'
            }],
            'ip': 0, 'op': 60, 'st': 0
        }]
    else:
        layers = [{
            'ddd': 0,
            'ind': 1,
            'ty': 4,
            'nm': 'shape',
            'sr': 1,
            'ks': {'o': {'a': 0, 'k': 100}, 'r': {'a': 0, 'k': 0}, 'p': {'a': 0, 'k': [100, 100, 0]}, 'a': {'a': 0, 'k': [0, 0, 0]}, 's': {'a': 0, 'k': [100, 100, 100]}},
            'ao': 0,
            'shapes': [{'ty': 'gr', 'it': [{'ty': 'rc', 'p': {'a': 0, 'k': [0, 0]}, 's': {'a': 0, 'k': [60, 60]}, 'r': {'a': 0, 'k': 20}, 'nm': 'Rect 1', 'hd': False}, {'ty': 'fl', 'c': {'a': 0, 'k': [0.1451, 0.3647, 0.9216, 1]}, 'o': {'a': 0, 'k': 100}, 'r': 1, 'nm': 'Fill 1'}], 'nm': 'Group 1', 'np': 2, 'cix': 2, 'bm': 0, 'ix': 1, 'mn': 'ADBE Vector Group'}],
            'ip': 0, 'op': 60, 'st': 0
        }]

    lottie = {
        'v': '5.10.0',
        'fr': 60,
        'ip': 0,
        'op': 60,
        'w': 200,
        'h': 200,
        'nm': name,
        'ddd': 0,
        'assets': [],
        'layers': layers,
    }
    path.write_text(json.dumps(lottie, indent=2), encoding='utf-8')


def write_pdf(path: Path, title: str, subtitle: str) -> None:
    content = f"""BT
/F1 24 Tf
100 500 Td
({title}) Tj
0 -40 Td
/F1 12 Tf
({subtitle}) Tj
ET"""
    # Simple minimal PDF bytes
    objects = []
    objects.append(b"<< /Type /Catalog /Pages 2 0 R >>")
    objects.append(b"<< /Type /Pages /Kids [3 0 R] /Count 1 >>")
    objects.append(b"<< /Type /Page /Parent 2 0 R /MediaBox [0 0 842 595] /Contents 4 0 R /Resources << /Font << /F1 5 0 R >> >> >>")
    objects.append(b"<< /Length 0 >>")
    # replace with actual content stream length
    stream = f"BT /F1 24 Tf 100 500 Td ({title}) Tj 0 -40 Td /F1 12 Tf ({subtitle}) Tj ET".encode('latin-1')
    objects[3] = f"<< /Length {len(stream)} >>".encode('latin-1')
    # build PDF with object stream
    pdf_parts = [b"%PDF-1.4\n"]
    offsets = [0]
    for obj in objects:
        offsets.append(len(b''.join(pdf_parts)))
        pdf_parts.append(f"{len(objects)-1} 0 obj\n".encode('latin-1'))
        pdf_parts.append(obj + b"\n")
        if len(objects) > 0 and obj == objects[3]:
            pdf_parts.append(b"stream\n")
            pdf_parts.append(stream + b"\n")
            pdf_parts.append(b"endstream\n")
        else:
            pass
    # build actual xref with correct object numbering
    # easier: write a compact, correct PDF for simple content
    pdf = bytearray()
    pdf.extend(b"%PDF-1.4\n")
    offsets = []
    offset = len(pdf)
    def add_obj(obj_bytes):
        nonlocal offset
        offsets.append(offset)
        pdf.extend(f"{len(offsets)} 0 obj\n".encode('latin-1'))
        pdf.extend(obj_bytes)
        pdf.extend(b"\nendobj\n")
        offset = len(pdf)
    # object 1 catalog
    add_obj(b"<< /Type /Catalog /Pages 2 0 R >>")
    add_obj(b"<< /Type /Pages /Kids [3 0 R] /Count 1 >>")
    add_obj(b"<< /Type /Page /Parent 2 0 R /MediaBox [0 0 842 595] /Contents 4 0 R /Resources << /Font << /F1 5 0 R >> >> >>")
    content_stream = f"BT /F1 24 Tf 100 500 Td ({title}) Tj 0 -40 Td /F1 12 Tf ({subtitle}) Tj ET".encode('latin-1')
    add_obj(f"<< /Length {len(content_stream)} >>\nstream\n".encode('latin-1') + content_stream + b"\nendstream")
    add_obj(b"<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>")
    xref_offset = len(pdf)
    pdf.extend(f"xref\n0 {len(offsets)+1}\n".encode('latin-1'))
    pdf.extend(b"0000000000 65535 f \n")
    for off in offsets:
        pdf.extend(f"{off:010d} 00000 n \n".encode('latin-1'))
    pdf.extend(f"trailer\n<< /Size {len(offsets)+1} /Root 1 0 R >>\nstartxref\n{xref_offset}\n%%EOF\n".encode('latin-1'))
    path.write_bytes(pdf)


if __name__ == '__main__':
    animations = [
        ('loading', 'pulse'),
        ('typing', 'pulse'),
        ('ai_thinking', 'pulse'),
        ('listening', 'pulse'),
        ('speaking', 'pulse'),
        ('voice_wave', 'wave'),
        ('lesson_complete', 'pulse'),
        ('badge_unlock', 'pulse'),
        ('xp_increase', 'pulse'),
        ('correct_answer', 'pulse'),
        ('wrong_answer', 'pulse'),
        ('confetti', 'pulse'),
        ('streak_fire', 'pulse'),
    ]
    for name, kind in animations:
        write_lottie(LOTTIE_DIR / f'{name}.json', name, kind)

    voice_wave_variants = [
        'idle',
        'listening',
        'speaking',
        'ai_response',
        'recording',
        'processing',
        'dark_mode',
        'light_mode',
    ]
    for name in voice_wave_variants:
        write_lottie(VOICE_DIR / f'voice_wave_{name}.json', name, 'wave')

    write_pdf(PDF_DIR / 'certificate_light.pdf', 'AI Language Coach', 'Completion Certificate')
    write_pdf(PDF_DIR / 'certificate_dark.pdf', 'AI Language Coach', 'Completion Certificate (Dark Theme)')

    print('Generated Lottie JSON files and certificate PDFs.')
