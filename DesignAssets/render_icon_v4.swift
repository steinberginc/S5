import AppKit
import CoreText

let canvas = 1024
let colorSpace = CGColorSpaceCreateDeviceRGB()
guard let context = CGContext(
    data: nil,
    width: canvas,
    height: canvas,
    bitsPerComponent: 8,
    bytesPerRow: canvas * 4,
    space: colorSpace,
    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
) else {
    fatalError("Could not create drawing context")
}

context.setFillColor(CGColor(red: 5 / 255, green: 5 / 255, blue: 5 / 255, alpha: 1))
context.fill(CGRect(x: 0, y: 0, width: canvas, height: canvas))

let font = CTFontCreateWithName("Futura-CondensedExtraBold" as CFString, 640, nil)
let white = CGColor(red: 247 / 255, green: 247 / 255, blue: 245 / 255, alpha: 1)

func drawGlyph(_ character: Character, x: CGFloat, baseline: CGFloat) {
    let scalar = character.unicodeScalars.first!.value
    var codeUnit = UniChar(scalar)
    var glyph = CGGlyph()
    guard CTFontGetGlyphsForCharacters(font, &codeUnit, &glyph, 1),
          let path = CTFontCreatePathForGlyph(font, glyph, nil) else {
        fatalError("Could not create glyph \(character)")
    }

    var athleticOblique = CGAffineTransform(a: 1, b: 0, c: 0.24, d: 1, tx: x, ty: baseline)
    guard let transformed = path.copy(using: &athleticOblique) else {
        fatalError("Could not transform glyph \(character)")
    }

    context.addPath(transformed)
    context.setFillColor(white)
    context.fillPath()
}

drawGlyph("S", x: 132, baseline: 192)
drawGlyph("5", x: 496, baseline: 192)

let bolt = CGMutablePath()
bolt.move(to: CGPoint(x: 592, y: 824))
bolt.addLine(to: CGPoint(x: 392, y: 505))
bolt.addLine(to: CGPoint(x: 486, y: 505))
bolt.addLine(to: CGPoint(x: 432, y: 194))
bolt.addLine(to: CGPoint(x: 642, y: 558))
bolt.addLine(to: CGPoint(x: 536, y: 558))
bolt.closeSubpath()

context.addPath(bolt)
context.setFillColor(CGColor(red: 225 / 255, green: 6 / 255, blue: 0, alpha: 1))
context.fillPath()

guard let image = context.makeImage() else {
    fatalError("Could not create final image")
}

let bitmap = NSBitmapImageRep(cgImage: image)
guard let png = bitmap.representation(using: .png, properties: [:]) else {
    fatalError("Could not encode PNG")
}

let output = URL(fileURLWithPath: CommandLine.arguments[1])
try png.write(to: output)
