//
//  SearchViewModel.swift
//  KakaoMap_Clone
//
//  Created by Sam Sung on 2023/05/23.
//

import Foundation

struct SearchOption {
    var icon: UIImage
    var title: String
}

class SearchViewModel {
    
    let searchOptions: [SearchOption] = {[
        SearchOption(icon: UIImage(systemName: "fork.knife")!, title: "맛집"),
        SearchOption(icon: UIImage(systemName: "cup.and.saucer.fill")!, title: "카페"),
        SearchOption(icon: UIImage(systemName: "24.square.fill")!, title: "편의점"),
        SearchOption(icon: UIImage(systemName: "cart.fill")!, title: "마트"),
        SearchOption(icon: UIImage(systemName: "pill.fill")!, title: "약국"),
        SearchOption(icon: UIImage(systemName: "train.side.rear.car")!, title: "지하철")
    ]}()
    
    func getCellWidth(with option: SearchOption) -> Double {
        if option.title.count <= 2 {
            return Double(option.title.count * 30)
        } else {
            return Double(option.title.count * 25)
        }
    }
}
