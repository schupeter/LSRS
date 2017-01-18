            for row in @rowsetArray
              xml.Row do
                xml.K(row[0])
                vs = row[1..-1]
                for v in vs do
                  xml.V(v)
                end # for v
              end # Row  
            end # for row
