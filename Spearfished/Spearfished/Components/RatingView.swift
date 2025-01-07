import SwiftUI

struct RatingView: View {
    @Binding var rating: Int
    let maximumRating: Int
    
    init(rating: Binding<Int>, maximumRating: Int = 5) {
        self._rating = rating
        self.maximumRating = maximumRating
    }
    
    var body: some View {
        HStack {
            ForEach(1...maximumRating, id: \.self) { number in
                Image(systemName: number <= rating ? "star.fill" : "star")
                    .foregroundStyle(Color(hue: 0.598, saturation: 0.584, brightness: 0.942))
                    .onTapGesture {
                        rating = number
                    }
            }
        }
        .font(.title2)
    }
} 