import UIKit
import ARCL
import SceneKit
import CoreLocation
import DiningStack

@available(iOS 11.0, *)
class ARViewController: UIViewController, CLLocationManagerDelegate {

    var sceneLocationView = SceneLocationView()
    var eateries: [Eatery] = []
    var nodes: [LocationNode] = []
    var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()

        sceneLocationView.run()
        view.addSubview(sceneLocationView)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(tapGesture)

        timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] timer in
            guard let `self` = self else { return }
            for node in self.nodes {
                self.sceneLocationView.removeLocationNode(locationNode: node)
            }
            self.nodes = []

            self.displayEateries()
        }

        timer?.fire()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        sceneLocationView.frame = view.bounds
    }

    @objc func viewTapped() {
        for node in nodes {
            sceneLocationView.removeLocationNode(locationNode: node)
        }

        timer?.invalidate()
        sceneLocationView.pause()
        sceneLocationView.removeFromSuperview()
        dismiss(animated: true, completion: nil)
    }

    func displayEateries() {
        for eatery in eateries {
            let frame = CGRect(x: 0.0, y: 0.0, width: 270.0, height: 54.0)
            let card = EateryARCard(frame: frame, eatery: eatery, userLocation: sceneLocationView.currentLocation())
            card.alpha = 0.8
            card.layer.cornerRadius = 4.0
            card.clipsToBounds = true

            let renderer = UIGraphicsImageRenderer(size: frame.size)
            let image = renderer.image { context in
                card.drawHierarchy(in: frame, afterScreenUpdates: true)
            }

            let scaledImage = UIImage(cgImage: image.cgImage!, scale: 0.1, orientation: image.imageOrientation)

            let location = CLLocation(coordinate: eatery.location.coordinate, altitude: 225)

            let node = LocationAnnotationNode(location: location, image: scaledImage)
            node.scaleRelativeToDistance = true

            sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: node)
            nodes.append(node)
        }
    }

}
