<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%
// controller 단
	// 제목 검색, 대여가능 검색
	String searchWord = request.getParameter("searchWord");
	if(request.getParameter("searchWord") == null) {
		searchWord = "";
	}
	
	String key = request.getParameter("key");
	if(request.getParameter("key") == null) {
		key = "";
	}
	if (key.equals("all")) { // 전체를 하기위해
	    key = "";
	}
		// 디버깅
		System.out.println("searchWord: " + searchWord);
		System.out.println("key: " + key);
	// 페이징
	int currentPage = 1;
		if(request.getParameter("currentPage") != null) {
			currentPage = Integer.parseInt(request.getParameter("currentPage"));
		}
	int rowPerPage = 10;
	int startRow = (currentPage - 1) * rowPerPage;
	
// model 단
	// 1) mysql 드라이버 로딩
	Class.forName("com.mysql.cj.jdbc.Driver");
		// 디버깅
		System.out.println("드라이버 연결 성공");
	// 변수 받기
	Connection conn = null;
	PreparedStatement stmt = null;
	ResultSet rs = null;
	// 페이징 변수 받기
	PreparedStatement stmt2 = null;
	ResultSet rs2 = null;
	
	// 2) sql 준비
	/* String listSql = "SELECT r.inventory_id invenId , f.title title, r.return_date reDate"
					+ " FROM rental r"
					+ " LEFT OUTER JOIN inventory i ON r.inventory_id = i.inventory_id"
					+ " INNER JOIN film f ON i.film_id = f.film_id"
					+ " WHERE (r.inventory_id, r.rental_date) IN (SELECT inventory_id, MAX(rental_date)"
					+ "	FROM rental"
					+ "	GROUP BY inventory_id)"; */
	
	String listSql = "SELECT t1.inventory_id invenId, t1.title title, t2.return_date reDate, isRental"
					 + " FROM"
		   			 + " (SELECT i.inventory_id, f.title"
		  			 + " FROM inventory i "
		      		 + " INNER JOIN film f ON i.film_id = f.film_id) t1"
		      		 + " LEFT OUTER JOIN"
		             + " (SELECT inventory_id, rental_date, return_date," 
		             + " CASE WHEN return_date IS NULL THEN '대여불가'"
		             + " ELSE '대여가능' END isRental"     
		     		 + " FROM rental" 
		      		 + " WHERE (inventory_id, rental_date)" 
		         	 + " IN (SELECT inventory_id, MAX(rental_date)"
		      		 + " FROM rental"
		      		 + " GROUP BY inventory_id)) t2"
		         	 + " ON t1.inventory_id = t2.inventory_id";
	
	String countSql = "SELECT count(*) cnt"
					 + " FROM"
		  			 + " (SELECT i.inventory_id, f.title"
		 			 + " FROM inventory i "
		     		 + " INNER JOIN film f ON i.film_id = f.film_id) t1"
		     		 + " LEFT OUTER JOIN"
		             + " (SELECT inventory_id, rental_date, return_date," 
		             + " CASE WHEN return_date IS NULL THEN '대여불가'"
		             + " ELSE '대여가능' END isRental"     
		    		 + " FROM rental" 
		     		 + " WHERE (inventory_id, rental_date)" 
		        	 + " IN (SELECT inventory_id, MAX(rental_date)"
		     		 + " FROM rental"
		     		 + " GROUP BY inventory_id)) t2"
		        	 + " ON t1.inventory_id = t2.inventory_id";
		// 디버깅
		System.out.println("listSql: " + listSql);
	// 3) connection (접속)하기
	conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/sakila", "root", "java1234");
	
		// 검색 + 카테고리 조건
		if(searchWord.equals("") && key.equals("")) { // 아무것도 하지 않았을 때
			listSql +=" ORDER BY t1.inventory_id LIMIT ?, ?";
			countSql += "";
			stmt = conn.prepareStatement(listSql);
			stmt2 = conn.prepareStatement(countSql);
			stmt.setInt(1, startRow);
			stmt.setInt(2, rowPerPage);
		
		} else if(!searchWord.equals("") && key.equals("")) { // 검색만 했을 때
			listSql += " WHERE t1.title like ? ORDER BY t1.inventory_id LIMIT ?, ?";
			countSql += " WHERE t1.title LIKE ?";
			stmt = conn.prepareStatement(listSql);
			stmt2 = conn.prepareStatement(countSql);
			stmt.setString(1, "%" + searchWord + "%");
			stmt.setInt(2, startRow);
			stmt.setInt(3, rowPerPage);
			stmt2.setString(1, "%" + searchWord + "%");
		
		} else if(searchWord.equals("") && !key.equals("")) { // 카테고리만 했을 때
			listSql += " WHERE isRental = ? ORDER BY t1.inventory_id LIMIT ?, ?";
			countSql += " WHERE isRental = ?";
			stmt = conn.prepareStatement(listSql);
			stmt2 = conn.prepareStatement(countSql);
			stmt.setString(1, key);
			stmt.setInt(2, startRow);
			stmt.setInt(3, rowPerPage);
			stmt2.setString(1, key);
		
		} else {						// 둘다 했을 때
			listSql += " WHERE t1.title LIKE ? AND isRental = ? ORDER BY t1.inventory_id LIMIT ?, ?";
			countSql += " WHERE t1.title LIKE ? AND isRental = ?";
			stmt = conn.prepareStatement(listSql);
			stmt2 = conn.prepareStatement(countSql);
			stmt.setString(1, "%" + searchWord + "%");
			stmt.setString(2, key);
			stmt.setInt(3, startRow);
			stmt.setInt(4, rowPerPage);
			stmt2.setString(1, "%" + searchWord + "%");
			stmt2.setString(2, key);
		}
	
	// 5) ResultSet 실행
	rs = stmt.executeQuery();
	rs2 = stmt2.executeQuery();
		// 디버깅
		System.out.println("ResultSet: " + rs);
		System.out.println("ResultSet: " + rs2);
		
		//전체 페이지
		int totalCnt = 0;
		if(rs2.next()) {
				totalCnt = rs2.getInt("cnt");
		}
		int lastPage = totalCnt / rowPerPage;
		if(totalCnt % rowPerPage != 0) {
			lastPage++;
		}
		// 디버깅 전체 행 수 출력 확인
				System.out.println("전체 행의 수: " + rs2.getInt("cnt"));
		
		// 페이징 수 나타내기
		int pageCount = 5;
		int startPage = ((currentPage - 1) / pageCount) * pageCount + 1;
		int endPage = startPage + pageCount - 1;
		if(endPage > lastPage) {
			endPage = lastPage;
		}
		
		// 배열리스트 받기
		ArrayList<HashMap<String, Object>> list = new ArrayList<HashMap<String, Object>>();
			while(rs.next()) {
				HashMap<String, Object> map = new HashMap<String, Object>();
				map.put("invenId", rs.getObject("invenId"));
				map.put("title", rs.getObject("title"));
				map.put("reDate", rs.getString("reDate"));
				map.put("isRental", rs.getObject("isRental"));
				
				list.add(map);
			}


%>

<!-- view 단 -->
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title></title>
<style>
		 .nolink {  /*링크 밑줄 제거 */
		 	text-decoration: none;
		 	color: black; /* 필요시 색상 지정 */
		 }
		 
		 	.nolink:hover {
		 		color: #FF0000; /* 마우스 오버 시 색상 변경 (빨강)*/
		 	}
		 	/*border말고 다른 테이블 코드*/
	 	table {
	 		width: 50%;
	 		border-collapse: separate; /* 중요: collapse명 둥글게 안 보임*/
	 		border-spacing: 50;		/* 셀 간격*/
	 		border-radius: 5px;		/* 둥근 모서리*/	
	 		overflow: hidden;        /* 꼭 필요: 둥근 모서리가 잘리지 않게*/
	 		box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1); /* 그림자도 예쁘게*/
	 		border: 2px solid #ccc;
	 	}	
	 	th, td {
	 		padding: 12px 16px;
	 		text-align: left;
	 		background-color: #fff;
	 		border: 1px solid #bbb;
	 	}
	 	
	 	th {
	 		background-color: #f4F4F4;
	 		font-weight: bold;
	 		color: #000;
	 	}
	 	
	 	th:nth-child(even) {
	 		background-color: #f9f9f9;
	 	}
	 	
	 	th:hover {
	 		background-color: #eef6ff;
	 	}
	 	
	</style>
</head>
<body>
	<h1>인벤토리 목록</h1>
		<table border="1">
			<tr>
				<th>번호</th>
				<th>영화제목</th>
				<th>반납일</th>
				<th>대여 여부</th>
			</tr>
			<%
				for(HashMap<String, Object> map : list) {
			%>
				<tr>
					<td><%=map.get("invenId") %></td>
					<td><%=map.get("title") %></td>
					<td><%=map.get("reDate") %></td>
					<td><a class="nolink" href="/sakila/d0327/inventoryOne.jsp?filmId=<%=map.get("filmId") %>"><%=map.get("isRental") %></td>
				</tr>
			<%
				}
			%>
		</table>
		<!-- 검색  -->
		<form action="/sakila/d0327/inventoryList.jsp">
		<select name="key">
			<option value="all"<%= key.equals("all") ? "selected" : "" %>>전체</option>
			<option value="대여가능"<%= key.equals("대여가능") ? "selected" : "" %>>대여가능</option>
			<option value="대여불가"<%= key.equals("대여불가") ? "selected" : "" %>>대여불가</option>
		</select>
		<input type="text" name="searchWord" value="<%=searchWord %>">
		<button type="submit">검색</button>
		<a href= "/sakila//d0327/inventoryList.jsp?">초기화</a>
		</form>
		<!-- 페이징 -->
		<a href="/sakila/d0327/inventoryList.jsp?currentPage=1&key=<%=key %>&searchWord=<%=searchWord %>">[처음]</a>
		<%
			// 10개 이전 할 경우
			if(currentPage > 1) {
				int prevPage = currentPage - 10;
				if(prevPage < 1) prevPage = 1;
		%>
			<a href="/sakila/d0327/inventoryList.jsp?currentPage=<%=prevPage %>&key=<%=key %>&searchWord=<%=searchWord %>">[이전]</a>
		<%
			}
			for(int i = startPage; i<= endPage; i++) {
		%>
			<a href="/sakila/d0327/inventoryList.jsp?currentPage=<%=i %>&key=<%=key %>&searchWord=<%=searchWord %>">[<%=i %>]</a>
		<%
			}
			// 10개 다음 할 경우
			if(currentPage < lastPage) {
				int nextPage = currentPage + 10;
				if(nextPage > lastPage) nextPage = lastPage;
		%>
			<a href="/sakila/d0327/inventoryList.jsp?currentPage=<%=nextPage %>&key=<%=key %>&searchWord=<%=searchWord %>">[다음]</a>
		<%
			}
		%>
			<a href="/sakila/d0327/inventoryList.jsp?currentPage=<%=lastPage %>&key=<%=key %>&searchWord=<%=searchWord %>">[마지막]</a>
</body>
</html>





