//
//  TableViewController.swift
//  Osiris
//
//  Created by 汤迪希 on 2018/9/25.
//  Copyright © 2018 DC. All rights reserved.
//

import UIKit

enum DataSource: String, CaseIterable {
    
    typealias RawValue = String
    
    case imageRender = "Image Rendering"
    case imageFilter = "Image Filtering"
    case cameraFilter = "Camera Filtering"
    case gifRender = "Gif Rendering"
    case imageTransform = "Image Transforming"
    case filterTransition = "Filter Transition"
    case videoPlaying = "Video Playing"
    case videoProcessing = "Video Processing"
    case opengl = "OpenGL Supporting"
}

class TableViewController: UITableViewController {

    lazy var dataSource:[DataSource] = DataSource.allCases
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension TableViewController {
    
    // MARK: - TableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath)
        cell.textLabel?.text = dataSource[indexPath.row].rawValue
        return cell
    }
    
    // MARK: - TableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch dataSource[indexPath.row] {
        case .imageRender:
            navigationController?.pushViewController(ImageRenderingController(), animated: true)
        case .imageFilter:
            navigationController?.pushViewController(ImageFilteringController(), animated: true)
        case .cameraFilter:
            navigationController?.pushViewController(CameraController(), animated: true)
        default:
            navigationController?.pushViewController(UIViewController(), animated: true)
        }
        
    }
}
