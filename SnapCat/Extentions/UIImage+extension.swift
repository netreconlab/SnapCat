//
//  UIImage+extension.swift
//  SnapCat
//
//  Created by Corey Baker on 7/4/21.
//  Copyright © 2021 Network Reconnaissance Lab. All rights reserved.
//

import Foundation
import UIKit

// Source: https://gist.github.com/alexruperez/90f44545b57c25b977c4
extension UIImage {
    func tint(_ color: UIColor, blendMode: CGBlendMode) -> UIImage {
        let drawRect = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, scale)

        if let context = UIGraphicsGetCurrentContext(), let mask = cgImage {
            context.clip(to: drawRect, mask: mask)
        }
        color.setFill()
        UIRectFill(drawRect)
        draw(in: drawRect, blendMode: blendMode, alpha: 1.0)

        if let tintedImage = UIGraphicsGetImageFromCurrentImageContext() {
            UIGraphicsEndImageContext()

            return tintedImage
        }
        return UIImage()
    }

    // Source: http://stackoverflow.com/questions/29137488/how-do-i-resize-the-uiimage-to-reduce-upload-image-size
    func resize(_ scale: CGFloat) -> UIImage {
        let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0),
                                                  size: CGSize(width: size.width*scale,
                                                               height: size.height*scale)))
        imageView.contentMode = UIView.ContentMode.scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContext(imageView.bounds.size)
        if let UIGraphicsGetCurrentContext = UIGraphicsGetCurrentContext() {
            imageView.layer.render(in: UIGraphicsGetCurrentContext)
        }

        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if let result = result {
            return result
        }

        return UIImage()
    }
    func resizeToWidth(_ width: CGFloat) -> UIImage {
        let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0),
                                                  size: CGSize(width: width,
                                                               height: width)))
        // imageView.contentMode = UIViewContentMode.ScaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContext(imageView.bounds.size)

        if let UIGraphicsGetCurrentContext = UIGraphicsGetCurrentContext() {
            imageView.layer.render(in: UIGraphicsGetCurrentContext)
        }
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if let result = result {
            return result
        }
        return UIImage()
    }

    func resizeToWidthHalfHeight(_ width: CGFloat) -> UIImage {
        let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0),
                                                  size: CGSize(width: width,
                                                               height: CGFloat(ceil(width/size.width * size.height)))))
        // imageView.contentMode = UIViewContentMode.ScaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContext(imageView.bounds.size)
        if let UIGraphicsGetCurrentContext = UIGraphicsGetCurrentContext() {
            imageView.layer.render(in: UIGraphicsGetCurrentContext)
        }

        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if let result = result {
            return result
        }
        return UIImage()
    }

    // Source: https://ruigomes.me/blog/how-to-rotate-an-uiimage-using-swift/
    func imageRotatedByDegrees(_ degrees: CGFloat, flip: Bool) -> UIImage {
        /*let radiansToDegrees: (CGFloat) -> CGFloat = {
            return $0 * (180.0 / CGFloat(M_PI))
        }*/
        let degreesToRadians: (CGFloat) -> CGFloat = {
            return $0 / 180.0 * CGFloat(Double.pi/*M_PI*/)
        }

        // calculate the size of the rotated view's containing box for our drawing space
        let rotatedViewBox = UIView(frame: CGRect(origin: CGPoint.zero, size: size))
        let transform = CGAffineTransform(rotationAngle: degreesToRadians(degrees))
        rotatedViewBox.transform = transform
        let rotatedSize = rotatedViewBox.frame.size

        // Create the bitmap context
        UIGraphicsBeginImageContext(rotatedSize)
        let bitmap = UIGraphicsGetCurrentContext()

        // Move the origin to the middle of the image so we will rotate and scale around the center.
        bitmap?.translateBy(x: rotatedSize.width / 2.0, y: rotatedSize.height / 2.0)

        //   // Rotate the image context
        bitmap?.rotate(by: degreesToRadians(degrees))

        // Now, draw the rotated/scaled image into the context
        var yFlip: CGFloat

        if flip {
            yFlip = CGFloat(-1.0)
        } else {
            yFlip = CGFloat(1.0)
        }

        bitmap?.scaleBy(x: yFlip, y: -1.0)
        bitmap?.draw(cgImage!,
                     in: CGRect(x: -size.width / 2,
                                y: -size.height / 2,
                                width: size.width,
                                height: size.height))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
}

// Source https://stackoverflow.com/questions/29726643/how-to-compress-of-reduce-the-size-of-an-image-before-uploading-to-parse-as-pffi/29726675
extension UIImage {
    // MARK: - UIImage+Resize
    func compressTo(_ expectedSizeInMb: Int) -> Data? {
        let sizeInBytes = expectedSizeInMb * 1024 * 1024
        var needCompress: Bool = true
        var imgData: Data?
        var compressingValue: CGFloat = 1.0
        while needCompress && compressingValue > 0.0 {
            if let data: Data = self.jpegData(compressionQuality: compressingValue) {
                if data.count < sizeInBytes {
                    needCompress = false
                    imgData = data
                } else {
                    compressingValue -= 0.1
                }
            }
        }

        if let data = imgData {
            if data.count < sizeInBytes {
                return data
            }
        }
        
        return nil
    }
}
