import UIKit
import ARCL
import SceneKit
import CoreLocation
import DiningStack

@available(iOS 11.0, *)
class ARViewController: UIViewController {

    var sceneLocationView = SceneLocationView()
    var eateries: [Eatery] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        sceneLocationView.run()
        view.addSubview(sceneLocationView)
        
        displayEateries()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(tapGesture)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        sceneLocationView.frame = view.bounds
    }

    @objc func viewTapped() {
        sceneLocationView.pause()
        sceneLocationView.removeFromSuperview()
        dismiss(animated: true, completion: nil)
    }

    func displayEateries() {
        for eatery in eateries {
            let frame = CGRect(x: 0.0, y: 0.0, width: 320.0, height: 54.0)
            let card = EateryARCard(frame: frame, eatery: eatery)

            let renderer = UIGraphicsImageRenderer(size: frame.size)
            let image = renderer.image { context in
                card.drawHierarchy(in: frame, afterScreenUpdates: true)
            }

            let scaledImage = UIImage(cgImage: image.cgImage!, scale: 0.1, orientation: image.imageOrientation)

            let location = CLLocation(coordinate: eatery.location.coordinate, altitude: 225)

            let node = LocationAnnotationNode(location: location, image: scaledImage)
            node.scaleRelativeToDistance = true


            sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: node)
        }
    }

}
